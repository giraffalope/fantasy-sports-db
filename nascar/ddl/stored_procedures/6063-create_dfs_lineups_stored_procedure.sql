-- dfs_lineups: stored procedure used by NASCAR DFS read-time consumers.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.
--
-- Server-side greedy lineup-difference selection for one (race, strategy).
-- SQL fallback when the Python submission selector
-- (fantasy-sports-airflow include/nascar/dfs/submission_portfolio.py) is not
-- available. For Double Up / GPP submission slates prefer the Python path
-- (correlation-aware, field-cutoff cash objective).
--
-- Parameters:
--   p_race_id                  Race identifier (nascar.races.id).
--   p_dfs_strategy_id          Strategy identifier (nascar.dfs_strategies.id).
--   p_min_driver_diff          Minimum different drivers between accepted pairs.
--   p_num_lineups              Maximum lineups to return.
--   p_max_driver_exposure_cap  Optional max fraction of lineups any driver may
--                              appear in (e.g. 0.25 for Double Up). NULL disables.
--
-- Result set columns (single result set; one row per (lineup, driver)):
--   lineup_rank, dfs_race_lineup_id, lineup_projected_points, lineup_salary,
--   driver_rank, driver_name, driver_dfs_id, driver_salary,
--   driver_projected_points, driver_actual_points
--
-- Output ordering: lineup_rank ASC, driver_rank ASC.

DROP PROCEDURE IF EXISTS `dfs_lineups`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dfs_lineups`(
    IN `p_race_id`                  BIGINT UNSIGNED,
    IN `p_dfs_strategy_id`          BIGINT UNSIGNED,
    IN `p_min_driver_diff`          INT UNSIGNED,
    IN `p_num_lineups`              INT UNSIGNED,
    IN `p_max_driver_exposure_cap`  DECIMAL(5, 4)
)
    COMMENT 'Server-side greedy min-driver-diff DFS lineup selection with optional per-driver exposure cap. Returns per-(lineup, driver) rows with projected and actual fantasy points.'
BEGIN
    DECLARE v_accepted_count     INT UNSIGNED DEFAULT 0;
    DECLARE v_lineup_id          BIGINT UNSIGNED DEFAULT 0;
    DECLARE v_lineup_size        INT UNSIGNED DEFAULT 0;
    DECLARE v_conflict_overlap   INT UNSIGNED DEFAULT 0;
    DECLARE v_exposure_conflict  INT UNSIGNED DEFAULT 0;
    DECLARE v_candidate_seq      INT UNSIGNED DEFAULT 0;
    DECLARE v_candidate_max      INT UNSIGNED DEFAULT 0;
    DECLARE v_min_diff_current   INT UNSIGNED DEFAULT 1;
    DECLARE v_driver_budget      INT UNSIGNED DEFAULT 0;
    DECLARE v_use_exposure       TINYINT UNSIGNED DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_candidates;
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;
        RESIGNAL;
    END;

    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_candidates;
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;

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

    CREATE TEMPORARY TABLE _dfs_lineups_exposure (
        car_driver_id BIGINT UNSIGNED NOT NULL,
        appearances   INT UNSIGNED    NOT NULL DEFAULT 0,
        PRIMARY KEY (car_driver_id)
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

    IF p_max_driver_exposure_cap IS NOT NULL
       AND p_max_driver_exposure_cap > 0
       AND p_num_lineups IS NOT NULL
       AND p_num_lineups > 0 THEN
        SET v_use_exposure = 1;
        SET v_driver_budget = CEILING(p_num_lineups * p_max_driver_exposure_cap);
        IF v_driver_budget < 1 THEN
            SET v_driver_budget = 1;
        END IF;
        IF v_driver_budget > p_num_lineups THEN
            SET v_driver_budget = p_num_lineups;
        END IF;
    END IF;

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

                IF EXISTS (
                    SELECT 1
                    FROM _dfs_lineups_accepted a
                    WHERE a.lineup_id = v_lineup_id
                ) THEN
                    ITERATE candidate_loop;
                END IF;

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

                IF v_use_exposure = 1 THEN
                    SELECT COUNT(*) INTO v_exposure_conflict
                    FROM nascar.dfs_race_lineups_car_drivers drlcd
                    LEFT JOIN _dfs_lineups_exposure e
                      ON e.car_driver_id = drlcd.car_driver_id
                    WHERE drlcd.dfs_race_lineup_id = v_lineup_id
                      AND drlcd.deleted_at         IS NULL
                      AND COALESCE(e.appearances, 0) >= v_driver_budget;

                    IF v_exposure_conflict > 0 THEN
                        ITERATE candidate_loop;
                    END IF;
                END IF;

                SET v_accepted_count = v_accepted_count + 1;

                INSERT INTO _dfs_lineups_accepted (lineup_id, lineup_rank)
                VALUES (v_lineup_id, v_accepted_count);

                IF v_use_exposure = 1 THEN
                    INSERT INTO _dfs_lineups_exposure (car_driver_id, appearances)
                    SELECT drlcd.car_driver_id, 1
                    FROM nascar.dfs_race_lineups_car_drivers drlcd
                    WHERE drlcd.dfs_race_lineup_id = v_lineup_id
                      AND drlcd.deleted_at         IS NULL
                    ON DUPLICATE KEY UPDATE
                        appearances = appearances + 1;
                END IF;
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
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;
END$$
DELIMITER ;
