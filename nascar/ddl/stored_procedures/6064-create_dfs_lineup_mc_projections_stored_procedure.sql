-- dfs_lineup_mc_projections: read-only audit/analytics procedure for persisted
-- DFS lineups enriched with per-driver Monte Carlo simulation summaries.
--
-- Complements nascar.dfs_lineups (diversified subset selection) by returning
-- the full persisted pool with lineup-level MC fingerprints and driver-level
-- ml_race_simulation_driver_summaries from the latest predict batch for the race week.
--
-- Parameters:
--   p_race_id           Race identifier (nascar.races.id).
--   p_dfs_strategy_id   Optional strategy filter (nascar.dfs_strategies.id).
--                       NULL returns all lineups for the race regardless of strategy.
--
-- Result set: one row per (lineup, driver), ordered by lineup rank then driver rank.
-- See SELECT column list below for full projection.

DROP PROCEDURE IF EXISTS `dfs_lineup_mc_projections`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `dfs_lineup_mc_projections`(
    IN `p_race_id`          BIGINT UNSIGNED,
    IN `p_dfs_strategy_id`  BIGINT UNSIGNED
)
    COMMENT 'Persisted DFS lineups for one race joined to latest MC driver summaries. Optional strategy filter. Read-only.'
BEGIN
    WITH driver_projections AS (
        SELECT
            ds.dfs_id,
            s.car_driver_id,
            d.id AS driver_id,
            TRIM(CONCAT(d.first_name, ' ', d.last_name, ' ', IFNULL(d.suffix, '')))
                AS driver_name,
            ds.salary,
            ds.dfs_driver_id,
            s.mean_dfs_points,
            s.std_dfs_points,
            s.min_dfs_points,
            s.p05_dfs_points,
            s.p50_dfs_points,
            s.p95_dfs_points,
            s.max_dfs_points,
            s.mean_r_finish_position,
            s.std_r_finish_position,
            s.min_r_finish_position,
            s.p05_r_finish_position,
            s.p50_r_finish_position,
            s.p95_r_finish_position,
            s.max_r_finish_position,
            s.mean_r_total_fastest_laps,
            s.std_r_total_fastest_laps,
            s.min_r_total_fastest_laps,
            s.p05_r_total_fastest_laps,
            s.p50_r_total_fastest_laps,
            s.p95_r_total_fastest_laps,
            s.max_r_total_fastest_laps,
            s.mean_r_total_laps_led,
            s.std_r_total_laps_led,
            s.min_r_total_laps_led,
            s.p05_r_total_laps_led,
            s.p50_r_total_laps_led,
            s.p95_r_total_laps_led,
            s.max_r_total_laps_led,
            s.dnf_pct
        FROM nascar.races r
        JOIN nascar.ml_training_snapshots snap
          ON snap.week_id = r.week_id
         AND snap.kind = 'predict'
         AND snap.deleted_at IS NULL
        JOIN nascar.ml_race_simulation_batches b
          ON b.ml_training_snapshot_id = snap.id
         AND b.deleted_at IS NULL
        JOIN nascar.ml_race_simulation_driver_summaries s
          ON s.ml_race_simulation_batch_id = b.id
         AND s.deleted_at IS NULL
        JOIN nascar.dfs_salaries ds
          ON ds.race_id = r.id
         AND ds.car_driver_id = s.car_driver_id
         AND ds.deleted_at IS NULL
        JOIN nascar.cars_drivers cd
          ON cd.id = ds.car_driver_id
         AND cd.deleted_at IS NULL
        JOIN nascar.drivers d
          ON d.id = cd.driver_id
         AND d.deleted_at IS NULL
        WHERE r.id = p_race_id
          AND r.deleted_at IS NULL
          AND b.id = (
              SELECT b2.id
              FROM nascar.ml_race_simulation_batches b2
              WHERE b2.ml_training_snapshot_id = snap.id
                AND b2.deleted_at IS NULL
              ORDER BY b2.id DESC
              LIMIT 1
          )
    ),
    lineup_projections AS (
        SELECT
            drl.race_id,
            drl.dfs_id,
            drl.id AS dfs_race_lineup_id,
            drl.projected_points_total AS lineup_projected_points,
            drl.salary_total AS lineup_salary,
            drl.mc_mean_dfs_points AS lineup_mc_mean_dfs_points,
            drl.mc_std_dfs_points AS lineup_mc_std_dfs_points,
            drl.mc_p10_dfs_points AS lineup_mc_p10_dfs_points,
            drl.mc_p50_dfs_points AS lineup_mc_p50_dfs_points,
            drl.mc_p90_dfs_points AS lineup_mc_p90_dfs_points,
            drl.mc_sharpe AS lineup_mc_sharpe,
            drl.mc_score_method AS lineup_mc_score_method,
            drlcd.car_driver_id,
            d.id AS driver_id,
            TRIM(CONCAT(d.first_name, ' ', d.last_name, ' ', IFNULL(d.suffix, '')))
                AS driver_name,
            drlcd.projected_points AS driver_projected_points,
            drlcd.salary AS driver_salary
        FROM nascar.dfs_race_lineups drl
        JOIN nascar.dfs_race_lineups_car_drivers drlcd
          ON drlcd.dfs_race_lineup_id = drl.id
         AND drlcd.deleted_at IS NULL
        JOIN nascar.cars_drivers cd
          ON cd.id = drlcd.car_driver_id
         AND cd.deleted_at IS NULL
        JOIN nascar.drivers d
          ON d.id = cd.driver_id
         AND d.deleted_at IS NULL
        WHERE drl.race_id = p_race_id
          AND drl.deleted_at IS NULL
          AND (
              p_dfs_strategy_id IS NULL
              OR EXISTS (
                  SELECT 1
                  FROM nascar.dfs_strategies_race_lineups dsrl
                  WHERE dsrl.dfs_race_lineup_id = drl.id
                    AND dsrl.dfs_strategy_id = p_dfs_strategy_id
                    AND dsrl.deleted_at IS NULL
              )
          )
    ),
    enriched AS (
        SELECT
            DENSE_RANK() OVER (
                ORDER BY
                    l.lineup_projected_points DESC,
                    l.lineup_salary ASC,
                    l.dfs_race_lineup_id ASC
            ) AS lineup_rank,
            l.dfs_race_lineup_id,
            l.lineup_projected_points,
            l.lineup_salary,
            l.lineup_mc_mean_dfs_points,
            l.lineup_mc_std_dfs_points,
            l.lineup_mc_p10_dfs_points,
            l.lineup_mc_p50_dfs_points,
            l.lineup_mc_p90_dfs_points,
            l.lineup_mc_sharpe,
            l.lineup_mc_score_method,
            ROW_NUMBER() OVER (
                PARTITION BY l.dfs_race_lineup_id
                ORDER BY l.driver_projected_points DESC, l.car_driver_id ASC
            ) AS driver_rank,
            l.driver_id,
            l.driver_name,
            l.driver_salary,
            l.driver_projected_points,
            d.mean_dfs_points AS driver_mean_dfs_points,
            d.std_dfs_points AS driver_std_dfs_points,
            d.min_dfs_points AS driver_min_dfs_points,
            d.p05_dfs_points AS driver_p05_dfs_points,
            d.p50_dfs_points AS driver_p50_dfs_points,
            d.p95_dfs_points AS driver_p95_dfs_points,
            d.max_dfs_points AS driver_max_dfs_points,
            d.mean_r_finish_position AS driver_mean_r_finish_position,
            d.std_r_finish_position AS driver_std_r_finish_position,
            d.min_r_finish_position AS driver_min_r_finish_position,
            d.p05_r_finish_position AS driver_p05_r_finish_position,
            d.p50_r_finish_position AS driver_p50_r_finish_position,
            d.p95_r_finish_position AS driver_p95_r_finish_position,
            d.max_r_finish_position AS driver_max_r_finish_position,
            d.mean_r_total_fastest_laps AS driver_mean_r_total_fastest_laps,
            d.std_r_total_fastest_laps AS driver_std_r_total_fastest_laps,
            d.min_r_total_fastest_laps AS driver_min_r_total_fastest_laps,
            d.p05_r_total_fastest_laps AS driver_p05_r_total_fastest_laps,
            d.p50_r_total_fastest_laps AS driver_p50_r_total_fastest_laps,
            d.p95_r_total_fastest_laps AS driver_p95_r_total_fastest_laps,
            d.max_r_total_fastest_laps AS driver_max_r_total_fastest_laps,
            d.mean_r_total_laps_led AS driver_mean_r_total_laps_led,
            d.std_r_total_laps_led AS driver_std_r_total_laps_led,
            d.min_r_total_laps_led AS driver_min_r_total_laps_led,
            d.p05_r_total_laps_led AS driver_p05_r_total_laps_led,
            d.p50_r_total_laps_led AS driver_p50_r_total_laps_led,
            d.p95_r_total_laps_led AS driver_p95_r_total_laps_led,
            d.max_r_total_laps_led AS driver_max_r_total_laps_led,
            d.dnf_pct AS driver_dnf_pct
        FROM lineup_projections l
        JOIN driver_projections d
          ON d.car_driver_id = l.car_driver_id
         AND d.dfs_id = l.dfs_id
    )
    SELECT
        lineup_rank,
        dfs_race_lineup_id,
        lineup_projected_points,
        lineup_salary,
        lineup_mc_mean_dfs_points,
        lineup_mc_std_dfs_points,
        lineup_mc_p10_dfs_points,
        lineup_mc_p50_dfs_points,
        lineup_mc_p90_dfs_points,
        lineup_mc_sharpe,
        lineup_mc_score_method,
        driver_rank,
        driver_id,
        driver_name,
        driver_salary,
        driver_projected_points,
        driver_mean_dfs_points,
        driver_std_dfs_points,
        driver_min_dfs_points,
        driver_p05_dfs_points,
        driver_p50_dfs_points,
        driver_p95_dfs_points,
        driver_max_dfs_points,
        driver_mean_r_finish_position,
        driver_std_r_finish_position,
        driver_min_r_finish_position,
        driver_p05_r_finish_position,
        driver_p50_r_finish_position,
        driver_p95_r_finish_position,
        driver_max_r_finish_position,
        driver_mean_r_total_fastest_laps,
        driver_std_r_total_fastest_laps,
        driver_min_r_total_fastest_laps,
        driver_p05_r_total_fastest_laps,
        driver_p50_r_total_fastest_laps,
        driver_p95_r_total_fastest_laps,
        driver_max_r_total_fastest_laps,
        driver_mean_r_total_laps_led,
        driver_std_r_total_laps_led,
        driver_min_r_total_laps_led,
        driver_p05_r_total_laps_led,
        driver_p50_r_total_laps_led,
        driver_p95_r_total_laps_led,
        driver_max_r_total_laps_led,
        driver_dnf_pct
    FROM enriched
    ORDER BY
        lineup_rank ASC,
        driver_rank ASC;
END$$
DELIMITER ;
