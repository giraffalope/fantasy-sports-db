-- Re-create the `nascar.dfs_lineups` stored procedure with the new
-- `dfs_race_lineup_id` column inserted between `lineup_rank` and
-- `lineup_projected_points` so downstream consumers can join the lineup
-- identity back to `nascar.dfs_race_lineups` (e.g. for audit, lineage,
-- or follow-up queries against the MC fingerprint columns).
--
-- Canonical DDL: nascar/ddl/stored_procedures/6063-create_dfs_lineups_stored_procedure.sql
--
-- Idempotent: DROP PROCEDURE IF EXISTS then CREATE; safe to re-run via
-- ./script/migrate (records in nascar.schema_migrations).

DROP PROCEDURE IF EXISTS `dfs_lineups`;
DELIMITER $$
CREATE PROCEDURE `dfs_lineups`(
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

    IF p_max_exposure_cap IS NULL OR p_max_exposure_cap <= 0 THEN
        SET v_budget = 0;
    ELSE
        SET v_budget = GREATEST(1, CEIL(p_num_lineups * p_max_exposure_cap));
    END IF;

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
