-- Re-create `nascar.dfs_lineups` with the diff-only API signature.
--
-- Breaking API change:
--   old: CALL nascar.dfs_lineups(p_race_id, p_dfs_strategy_id, p_max_exposure_cap, p_num_lineups)
--   new: CALL nascar.dfs_lineups(p_race_id, p_dfs_strategy_id, p_min_driver_diff, p_num_lineups)
--
-- Canonical DDL:
--   nascar/ddl/stored_procedures/6063-create_dfs_lineups_stored_procedure.sql
-- Mirrors the Python `greedy_diversify` in fantasy-sports-airflow
-- include/nascar/dfs/lineup_portfolio.py but operates over the persisted pool
-- in nascar.dfs_race_lineups instead of a candidate pool. Read-only.
--
-- Parameters:
--   p_race_id           Race identifier (nascar.races.id).
--   p_dfs_strategy_id   Strategy identifier (nascar.dfs_strategies.id; resolve
--                       by name with `SELECT id FROM nascar.dfs_strategies
--                       WHERE name = 'DOUBLE_UP'`).
--   p_min_driver_diff   Minimum number of different drivers required between
--                       any accepted lineup pair during the strict phase.
--                       The selector relaxes this threshold downward (N, N-1,
--                       ... 1) when needed to fill `p_num_lineups`.
--   p_num_lineups       Maximum lineups to return. The procedure may return
--                       fewer if the persisted pool is too concentrated to
--                       satisfy lineup-difference rules.
--
-- Result set columns (single result set; one row per (lineup, driver)):
--   lineup_rank                INT UNSIGNED      Rank within result by objective_value DESC.
--   dfs_race_lineup_id         BIGINT UNSIGNED   nascar.dfs_race_lineups.id (lineup identity).
--   lineup_projected_points    DECIMAL(14,2)     dfs_race_lineups.projected_points_total.
--   lineup_salary              INT UNSIGNED      dfs_race_lineups.salary_total.
--   driver_rank                INT UNSIGNED      Rank within lineup by projected_points DESC.
--   driver_name                VARCHAR           "first last suffix" (trimmed).
--   driver_dfs_id              BIGINT UNSIGNED   DraftKings driver id (snapshotted at lineup write).
--   driver_salary              INT UNSIGNED      Per-driver salary (snapshotted).
--   driver_projected_points    DECIMAL(14,2)     Per-driver projected (snapshotted).
--   driver_actual_points       DECIMAL(14,3)     ml_labels.dfs_points for the latest train
--                                                snapshot covering (week_id, dfs_id);
--                                                NULL pre-race.
--
-- Output ordering: lineup_rank ASC, driver_rank ASC.

DROP PROCEDURE IF EXISTS `dfs_lineups`;
DELIMITER $$
CREATE PROCEDURE `dfs_lineups`(
    IN `p_race_id`          BIGINT UNSIGNED,
    IN `p_dfs_strategy_id`  BIGINT UNSIGNED,
    IN `p_min_driver_diff`  INT UNSIGNED,
    IN `p_num_lineups`      INT UNSIGNED
)
    COMMENT 'Server-side greedy min-driver-diff DFS lineup selection for one (race, strategy). Returns per-(lineup, driver) rows with projected and actual fantasy points.'
BEGIN
    DECLARE v_accepted_count     INT UNSIGNED DEFAULT 0;
    DECLARE v_lineup_id          BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_lineup_size        INT UNSIGNED DEFAULT 0;
    DECLARE v_conflict_overlap   INT UNSIGNED DEFAULT 0;
    DECLARE v_candidate_seq      INT UNSIGNED DEFAULT 0;
    DECLARE v_candidate_max      INT UNSIGNED DEFAULT 0;
    DECLARE v_min_diff_current   INT UNSIGNED DEFAULT 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_candidates;
        RESIGNAL;
    END;

    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_candidates;

    CREATE TEMPORARY TABLE _dfs_lineups_accepted (
        lineup_id   BIGINT UNSIGNED NOT NULL,
        lineup_rank INT UNSIGNED    NOT NULL,
        PRIMARY KEY (lineup_id),
        KEY idx_rank (lineup_rank)
    ) ENGINE=Memory;

    CREATE TEMPORARY TABLE _dfs_lineups_candidates (
        seq       INT UNSIGNED NOT NULL AUTO_INCREMENT,
        lineup_id BIGINT UNSIGNED NOT NULL,
        PRIMARY KEY (seq),
        UNIQUE KEY uq_lineup (lineup_id)
    ) ENGINE=Memory;

    INSERT INTO _dfs_lineups_candidates (lineup_id)
    SELECT drl.id
    FROM nascar.dfs_race_lineups drl
    JOIN nascar.dfs_strategies_race_lineups dsrl
      ON dsrl.dfs_race_lineup_id = drl.id
     AND dsrl.deleted_at IS NULL
    WHERE drl.race_id          = p_race_id
      AND dsrl.dfs_strategy_id = p_dfs_strategy_id
      AND drl.deleted_at       IS NULL
    ORDER BY drl.objective_value DESC, drl.id ASC;

    SELECT COALESCE(MAX(seq), 0) INTO v_candidate_max
    FROM _dfs_lineups_candidates;

    IF p_num_lineups IS NULL OR p_num_lineups = 0 OR v_candidate_max = 0 THEN
        SET v_accepted_count = COALESCE(p_num_lineups, 0);
    ELSE
        SET v_min_diff_current = GREATEST(1, COALESCE(p_min_driver_diff, 1));

        phase_loop: WHILE v_accepted_count < p_num_lineups AND v_min_diff_current >= 1 DO
            SET v_candidate_seq = 1;

            candidate_loop: WHILE v_candidate_seq <= v_candidate_max DO
                IF v_accepted_count >= p_num_lineups THEN
                    LEAVE candidate_loop;
                END IF;

                SELECT c.lineup_id INTO v_lineup_id
                FROM _dfs_lineups_candidates c
                WHERE c.seq = v_candidate_seq;
                SET v_candidate_seq = v_candidate_seq + 1;

                -- Already accepted in an earlier phase.
                IF EXISTS (
                    SELECT 1
                    FROM _dfs_lineups_accepted a
                    WHERE a.lineup_id = v_lineup_id
                ) THEN
                    ITERATE candidate_loop;
                END IF;

                -- Overlap conflict: reject when candidate differs by fewer than
                -- v_min_diff_current drivers from any accepted lineup.
                SELECT COUNT(*) INTO v_lineup_size
                FROM nascar.dfs_race_lineups_car_drivers drlcd
                WHERE drlcd.dfs_race_lineup_id = v_lineup_id
                  AND drlcd.deleted_at         IS NULL;

                IF v_lineup_size = 0 THEN
                    ITERATE candidate_loop;
                END IF;

                SELECT COUNT(*) INTO v_conflict_overlap
                FROM _dfs_lineups_accepted a
                WHERE (
                    SELECT COUNT(*)
                    FROM nascar.dfs_race_lineups_car_drivers c1
                    JOIN nascar.dfs_race_lineups_car_drivers c2
                      ON c2.car_driver_id         = c1.car_driver_id
                     AND c2.dfs_race_lineup_id    = a.lineup_id
                     AND c2.deleted_at            IS NULL
                    WHERE c1.dfs_race_lineup_id   = v_lineup_id
                      AND c1.deleted_at           IS NULL
                ) > (v_lineup_size - v_min_diff_current);

                IF v_conflict_overlap > 0 THEN
                    ITERATE candidate_loop;
                END IF;

                SET v_accepted_count = v_accepted_count + 1;

                INSERT INTO _dfs_lineups_accepted (lineup_id, lineup_rank)
                VALUES (v_lineup_id, v_accepted_count);
            END WHILE;

            IF v_accepted_count >= p_num_lineups THEN
                LEAVE phase_loop;
            END IF;

            IF v_min_diff_current = 1 THEN
                LEAVE phase_loop;
            END IF;

            SET v_min_diff_current = v_min_diff_current - 1;
        END WHILE;
    END IF;

    SELECT
        a.lineup_rank                                AS lineup_rank,
        drl.id                                       AS dfs_race_lineup_id,
        drl.projected_points_total                   AS lineup_projected_points,
        drl.salary_total                             AS lineup_salary,
        ROW_NUMBER() OVER (
            PARTITION BY a.lineup_id
            ORDER BY drlcd.projected_points DESC, drlcd.id ASC
        )                                            AS driver_rank,
        TRIM(CONCAT(d.first_name, ' ', d.last_name, ' ', IFNULL(d.suffix, '')))
                                                     AS driver_name,
        drlcd.dfs_driver_id                          AS driver_dfs_id,
        drlcd.salary                                 AS driver_salary,
        drlcd.projected_points                       AS driver_projected_points,
        l.dfs_points                                 AS driver_actual_points
    FROM _dfs_lineups_accepted a
    JOIN nascar.dfs_race_lineups drl
      ON drl.id        = a.lineup_id
     AND drl.deleted_at IS NULL
    JOIN nascar.dfs_race_lineups_car_drivers drlcd
      ON drlcd.dfs_race_lineup_id = a.lineup_id
     AND drlcd.deleted_at         IS NULL
    JOIN nascar.cars_drivers cd
      ON cd.id        = drlcd.car_driver_id
     AND cd.deleted_at IS NULL
    JOIN nascar.drivers d
      ON d.id        = cd.driver_id
     AND d.deleted_at IS NULL
    JOIN nascar.races r
      ON r.id        = drl.race_id
     AND r.deleted_at IS NULL
    LEFT JOIN nascar.ml_training_snapshots s
      ON s.id = (
            SELECT MAX(s2.id)
            FROM nascar.ml_training_snapshots s2
            WHERE s2.week_id    = r.week_id
              AND s2.dfs_id     = drl.dfs_id
              AND s2.kind       = 'train'
              AND s2.deleted_at IS NULL
         )
    LEFT JOIN nascar.ml_labels l
      ON l.ml_training_snapshot_id = s.id
     AND l.car_driver_id           = drlcd.car_driver_id
     AND l.deleted_at               IS NULL
    ORDER BY a.lineup_rank ASC, driver_rank ASC;

    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_candidates;
END$$
DELIMITER ;
