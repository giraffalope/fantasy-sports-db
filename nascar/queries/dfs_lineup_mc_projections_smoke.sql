-- Smoke caller for the `nascar.dfs_lineup_mc_projections` stored procedure.
--
-- Returns the full persisted lineup pool for one race, enriched with
-- lineup-level MC fingerprints and per-driver Monte Carlo summary stats
-- from the latest predict batch. Use this for audit/analytics; use
-- `nascar.dfs_lineups` when you need a diversified N-lineup slate.
--
-- Parameters (positional):
--   1) p_race_id          BIGINT UNSIGNED
--   2) p_dfs_strategy_id  BIGINT UNSIGNED  NULL = all strategies
--
-- Result set (one row per lineup driver):
--   lineup_rank is shared by all drivers in the same lineup (DENSE_RANK).
--   lineup_rank, dfs_race_lineup_id, lineup_projected_points, lineup_salary,
--   lineup_mc_* fingerprint columns, driver_rank, driver_id, driver_name,
--   driver_salary, driver_projected_points, driver_* MC summary columns
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

-- 3) All strategies for the race.
SET @race_id = <PASTE_RACE_ID>;

CALL nascar.dfs_lineup_mc_projections(@race_id, NULL);

-- 4) Optional: one strategy only.
SET @strategy_id = (SELECT id FROM nascar.dfs_strategies WHERE name = 'DOUBLE_UP' LIMIT 1);

CALL nascar.dfs_lineup_mc_projections(@race_id, @strategy_id);

-- 5) Sanity: row count should equal 6 * number of lineups returned.
-- SELECT COUNT(*) / 6 AS approx_lineup_count FROM (... paste result ...);
