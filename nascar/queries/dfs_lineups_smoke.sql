-- Smoke caller for the `nascar.dfs_lineups` stored procedure.
--
-- The procedure mirrors the Python `greedy_diversify` selector in
-- fantasy-sports-airflow include/nascar/dfs/lineup_portfolio.py but runs
-- server-side over the persisted pool in `nascar.dfs_race_lineups`,
-- letting downstream consumers ask for a diverse N-lineup slate without
-- re-implementing the algorithm in app code.
--
-- Parameters (positional):
--   1) p_race_id          BIGINT UNSIGNED
--   2) p_dfs_strategy_id  BIGINT UNSIGNED  (resolve by name; see below)
--   3) p_min_driver_diff  INT UNSIGNED      (minimum different drivers required
--                                           between accepted lineup pairs; selector
--                                           relaxes downward to fill N as needed)
--   4) p_num_lineups      INT UNSIGNED
--
-- Result set (single result set, one row per (lineup, driver)):
--   lineup_rank, dfs_race_lineup_id, lineup_projected_points,
--   lineup_salary, driver_rank, driver_name, driver_dfs_id,
--   driver_salary, driver_projected_points, driver_actual_points
--
-- Output ordering: lineup_rank ASC, driver_rank ASC.
--
-- Replace the constants below before running.

-- 1) Look up the latest race id for the current Cup week (adjust as needed).
SELECT r.id AS race_id, w.id AS week_id, w.race_name, w.scheduled_start
FROM nascar.races r
JOIN nascar.weeks w ON w.id = r.week_id AND w.deleted_at IS NULL
JOIN nascar.seasons s ON s.id = w.season_id AND s.deleted_at IS NULL
JOIN nascar.series sr ON sr.id = s.series_id AND sr.deleted_at IS NULL
WHERE sr.name = 'Cup Series'
  AND r.deleted_at IS NULL
ORDER BY w.scheduled_start DESC
LIMIT 5;

-- 2) Resolve strategy ids (DOUBLE_UP for cash, HIGH_RISK_REWARD for GPP).
SELECT id, name
FROM nascar.dfs_strategies
WHERE name IN ('DOUBLE_UP', 'HIGH_RISK_REWARD')
  AND deleted_at IS NULL
ORDER BY name;

-- 3) Call the procedure. Set the race_id and strategy_id from steps (1) and (2).
SET @race_id          = <PASTE_RACE_ID>;
SET @strategy_id      = (SELECT id FROM nascar.dfs_strategies WHERE name = 'HIGH_RISK_REWARD' LIMIT 1);
SET @min_driver_diff  = 2;
SET @num_lineups      = 20;

CALL nascar.dfs_lineups(@race_id, @strategy_id, @min_driver_diff, @num_lineups);

-- 4) Optional: verify pairwise lineup overlap and resulting per-driver frequency.
--    Re-run the proc into a temp table for offline analysis:
--      DROP TEMPORARY TABLE IF EXISTS _smoke_lineups;
--      CREATE TEMPORARY TABLE _smoke_lineups (
--          lineup_rank             INT UNSIGNED,
--          dfs_race_lineup_id      BIGINT UNSIGNED,
--          lineup_projected_points DECIMAL(14,2),
--          lineup_salary           INT UNSIGNED,
--          driver_rank             INT UNSIGNED,
--          driver_name             VARCHAR(255),
--          driver_dfs_id           BIGINT UNSIGNED,
--          driver_salary           INT UNSIGNED,
--          driver_projected_points DECIMAL(14,2),
--          driver_actual_points    DECIMAL(14,3)
--      );
--      -- ... INSERT INTO _smoke_lineups ... but MariaDB stored procedures cannot be the
--      -- direct source of an INSERT...SELECT; run the proc in the client and copy/paste,
--      -- or use a wrapper view if exposure analytics become a recurring need.
