-- dfs_lineups: stored procedure used by NASCAR DFS read-time consumers.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.
--
-- Server-side greedy exposure-capped lineup selection for one (race, strategy).
-- Mirrors the Python `greedy_diversify` in fantasy-sports-airflow
-- include/nascar/dfs/lineup_portfolio.py but operates over the persisted pool
-- in nascar.dfs_race_lineups instead of a candidate pool. Read-only.
--
-- Parameters:
--   p_race_id           Race identifier (nascar.races.id).
--   p_dfs_strategy_id   Strategy identifier (nascar.dfs_strategies.id; resolve
--                       by name with `SELECT id FROM nascar.dfs_strategies
--                       WHERE name = 'DOUBLE_UP'`).
--   p_max_exposure_cap  Max fraction of returned lineups any single driver
--                       may appear in. Per-driver budget computed as
--                       CEIL(p_num_lineups * p_max_exposure_cap) (>= 1 when
--                       the cap is positive; 0 when the cap is 0, which
--                       returns an empty result set).
--   p_num_lineups       Maximum lineups to return. The procedure may return
--                       fewer if the persisted pool is too concentrated to
--                       satisfy the cap (no relaxation; call again with a
--                       higher cap if a fuller slate is required).
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `dfs_lineups`(
    IN `p_race_id`          BIGINT UNSIGNED,
    IN `p_dfs_strategy_id`  BIGINT UNSIGNED,
    IN `p_max_exposure_cap` DECIMAL(5,4),
    IN `p_num_lineups`      INT UNSIGNED
)
    COMMENT 'Server-side greedy exposure-capped DFS lineup selection for one (race, strategy). Returns per-(lineup, driver) rows with projected and actual fantasy points.'
BEGIN
    DECLARE v_done           INT DEFAULT 0;
    DECLARE v_budget         INT UNSIGNED DEFAULT 0;
    DECLARE v_accepted_count INT UNSIGNED DEFAULT 0;
    DECLARE v_lineup_id      BIGINT UNSIGNED;
    DECLARE v_conflict       INT UNSIGNED DEFAULT 0;

    DECLARE cur_lineups CURSOR FOR
        SELECT drl.id
        FROM nascar.dfs_race_lineups drl
        JOIN nascar.dfs_strategies_race_lineups dsrl
          ON dsrl.dfs_race_lineup_id = drl.id
         AND dsrl.deleted_at IS NULL
        WHERE drl.race_id            = p_race_id
          AND dsrl.dfs_strategy_id   = p_dfs_strategy_id
          AND drl.deleted_at         IS NULL
        ORDER BY drl.objective_value DESC, drl.id ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
        DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;
        RESIGNAL;
    END;

    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_accepted;
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;

    CREATE TEMPORARY TABLE _dfs_lineups_accepted (
        lineup_id   BIGINT UNSIGNED NOT NULL,
        lineup_rank INT UNSIGNED    NOT NULL,
        PRIMARY KEY (lineup_id),
        KEY idx_rank (lineup_rank)
    ) ENGINE=Memory;

    CREATE TEMPORARY TABLE _dfs_lineups_exposure (
        car_driver_id BIGINT UNSIGNED NOT NULL,
        cnt           INT UNSIGNED    NOT NULL DEFAULT 0,
        PRIMARY KEY (car_driver_id)
    ) ENGINE=Memory;

    -- Mirrors `_per_driver_budget` in lineup_portfolio.py: cap<=0 admits nothing,
    -- otherwise CEIL(target * cap) with a floor of 1.
    IF p_max_exposure_cap IS NULL OR p_max_exposure_cap <= 0 THEN
        SET v_budget = 0;
    ELSE
        SET v_budget = GREATEST(1, CEIL(p_num_lineups * p_max_exposure_cap));
    END IF;

    -- Short-circuit when no lineups can be admitted (cap=0 or count=0).
    -- The main loop's guard handles this path by exiting before any FETCH.
    IF v_budget = 0 OR p_num_lineups = 0 THEN
        SET v_accepted_count = COALESCE(p_num_lineups, 0);
    END IF;

    OPEN cur_lineups;
    read_loop: LOOP
        IF v_accepted_count >= p_num_lineups THEN
            LEAVE read_loop;
        END IF;

        FETCH cur_lineups INTO v_lineup_id;
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- A candidate lineup conflicts when any of its drivers has already
        -- consumed the per-driver budget. COUNT(*) avoids the SELECT INTO
        -- NOT FOUND condition that would otherwise trip our cursor handler.
        SELECT COUNT(*) INTO v_conflict
        FROM nascar.dfs_race_lineups_car_drivers drlcd
        JOIN _dfs_lineups_exposure e
          ON e.car_driver_id = drlcd.car_driver_id
        WHERE drlcd.dfs_race_lineup_id = v_lineup_id
          AND drlcd.deleted_at         IS NULL
          AND e.cnt                    >= v_budget;

        IF v_conflict = 0 THEN
            SET v_accepted_count = v_accepted_count + 1;

            INSERT INTO _dfs_lineups_accepted (lineup_id, lineup_rank)
            VALUES (v_lineup_id, v_accepted_count);

            INSERT INTO _dfs_lineups_exposure (car_driver_id, cnt)
            SELECT drlcd.car_driver_id, 1
            FROM nascar.dfs_race_lineups_car_drivers drlcd
            WHERE drlcd.dfs_race_lineup_id = v_lineup_id
              AND drlcd.deleted_at         IS NULL
            ON DUPLICATE KEY UPDATE cnt = cnt + 1;
        END IF;
    END LOOP;
    CLOSE cur_lineups;

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
    DROP TEMPORARY TABLE IF EXISTS _dfs_lineups_exposure;
END$$
DELIMITER ;
