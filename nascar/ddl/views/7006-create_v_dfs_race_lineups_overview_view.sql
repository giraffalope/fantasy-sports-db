-- v_dfs_race_lineups_overview: DFS race lineups with strategy (via pivot) and driver rows.

DROP VIEW IF EXISTS `v_dfs_race_lineups_overview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dfs_race_lineups_overview` AS
WITH dfs_lineups AS (
    SELECT
        drl.id AS dfs_race_lineup_id,
        drl.dfs_id AS dfs_id,
        drl.race_id AS race_id,
        ds.id AS dfs_strategy_id,
        ds.name AS strategy,
        drl.projected_points_total AS projected_points_total,
        drl.salary_total AS salary_total
    FROM nascar.dfs_race_lineups drl
    JOIN nascar.dfs_strategies_race_lineups dsrl
        ON dsrl.dfs_race_lineup_id = drl.id
        AND dsrl.deleted_at IS NULL
    JOIN nascar.dfs_strategies ds
        ON ds.id = dsrl.dfs_strategy_id
        AND ds.deleted_at IS NULL
    WHERE drl.deleted_at IS NULL
),
dfs_lineup_drivers AS (
    SELECT
        drlcd.dfs_race_lineup_id AS dfs_race_lineup_id,
        drlcd.dfs_driver_id AS dfs_driver_id,
        cd.car_id AS car_id,
        d.id AS driver_id,
        TRIM(CONCAT(d.first_name, ' ', d.last_name, ' ', IFNULL(d.suffix, ''))) AS driver_name,
        drlcd.salary AS salary,
        drlcd.projected_points AS projected_points
    FROM nascar.dfs_race_lineups_car_drivers drlcd
    JOIN nascar.cars_drivers cd
        ON cd.id = drlcd.car_driver_id
        AND cd.deleted_at IS NULL
    JOIN nascar.drivers d
        ON d.id = cd.driver_id
        AND d.deleted_at IS NULL
    WHERE drlcd.deleted_at IS NULL
)
SELECT *
FROM dfs_lineups dl
JOIN dfs_lineup_drivers dld USING (dfs_race_lineup_id)
ORDER BY dl.race_id, dl.strategy, dl.projected_points_total DESC, dl.salary_total ASC,
    dld.projected_points DESC, dld.salary ASC
;
