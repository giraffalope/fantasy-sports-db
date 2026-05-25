-- v_dfs_strategies_drivers_exposure: per race and dfs_strategies row, driver lineup exposure.
-- exposure_pct = 100 * (lineups containing driver) / (total lineups for race + strategy).

DROP VIEW IF EXISTS `v_dfs_lineups_drivers_exposure`;
DROP VIEW IF EXISTS `v_dfs_strategies_drivers_exposure`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dfs_strategies_drivers_exposure` AS
WITH active_lineups AS (
    SELECT
        drl.id AS dfs_race_lineup_id,
        drl.race_id AS race_id,
        ds.id AS dfs_strategy_id,
        ds.name AS strategy
    FROM nascar.dfs_race_lineups drl
    JOIN nascar.dfs_strategies_race_lineups dsrl
        ON dsrl.dfs_race_lineup_id = drl.id
        AND dsrl.deleted_at IS NULL
    JOIN nascar.dfs_strategies ds
        ON ds.id = dsrl.dfs_strategy_id
        AND ds.deleted_at IS NULL
    WHERE drl.deleted_at IS NULL
),
lineup_totals AS (
    SELECT
        al.race_id AS race_id,
        al.dfs_strategy_id AS dfs_strategy_id,
        al.strategy AS strategy,
        COUNT(DISTINCT al.dfs_race_lineup_id) AS lineup_total
    FROM active_lineups al
    GROUP BY al.race_id, al.dfs_strategy_id, al.strategy
),
driver_appearances AS (
    SELECT
        al.race_id AS race_id,
        al.dfs_strategy_id AS dfs_strategy_id,
        al.strategy AS strategy,
        cd.driver_id AS driver_id,
        COUNT(DISTINCT al.dfs_race_lineup_id) AS lineup_count
    FROM active_lineups al
    JOIN nascar.dfs_race_lineups_car_drivers drlcd
        ON drlcd.dfs_race_lineup_id = al.dfs_race_lineup_id
        AND drlcd.deleted_at IS NULL
    JOIN nascar.cars_drivers cd
        ON cd.id = drlcd.car_driver_id
        AND cd.deleted_at IS NULL
    GROUP BY al.race_id, al.dfs_strategy_id, al.strategy, cd.driver_id
)
SELECT
    da.race_id AS race_id,
    da.dfs_strategy_id AS dfs_strategy_id,
    da.strategy AS strategy,
    da.driver_id AS driver_id,
    TRIM(CONCAT(d.first_name, ' ', d.last_name, ' ', IFNULL(d.suffix, ''))) AS driver_name,
    da.lineup_count AS lineup_count,
    lt.lineup_total AS lineup_total,
    CASE
        WHEN lt.lineup_total = 0 THEN NULL
        ELSE ROUND(100.0 * da.lineup_count / lt.lineup_total, 2)
    END AS exposure_pct
FROM driver_appearances da
JOIN lineup_totals lt
    ON lt.race_id = da.race_id
    AND lt.dfs_strategy_id = da.dfs_strategy_id
    AND lt.strategy = da.strategy
JOIN nascar.drivers d
    ON d.id = da.driver_id
    AND d.deleted_at IS NULL
;
