-- dfs_strategies lookup + dfs_strategies_race_lineups pivot; drop dfs_race_lineups.strategy enum.
-- Renames exposure view to v_dfs_strategies_drivers_exposure.
-- Canonical DDL: nascar/ddl/tables/1080-*.sql, 1081-*.sql, views/7006, 7008.

DROP VIEW IF EXISTS `v_dfs_lineups_drivers_exposure`;
DROP VIEW IF EXISTS `v_dfs_strategies_drivers_exposure`;
DROP VIEW IF EXISTS `v_dfs_race_lineups_overview`;

CREATE TABLE IF NOT EXISTS `dfs_strategies` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `name` varchar(64) NOT NULL COMMENT 'Stable strategy identifier (e.g. DOUBLE_UP, HIGH_RISK_REWARD).',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='DFS lineup strategy buckets.';

ALTER TABLE `dfs_strategies` ADD UNIQUE KEY `unique_dfs_strategies_name` (`name`);

INSERT INTO nascar.dfs_strategies (name)
SELECT 'DOUBLE_UP' FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM nascar.dfs_strategies WHERE name = 'DOUBLE_UP' AND deleted_at IS NULL
);

INSERT INTO nascar.dfs_strategies (name)
SELECT 'HIGH_RISK_REWARD' FROM DUAL
WHERE NOT EXISTS (
    SELECT 1 FROM nascar.dfs_strategies WHERE name = 'HIGH_RISK_REWARD' AND deleted_at IS NULL
);

CREATE TABLE IF NOT EXISTS `dfs_strategies_race_lineups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `dfs_strategy_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to dfs_strategies.',
  `dfs_race_lineup_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to dfs_race_lineups.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_dfs_strategies_race_lineups_strategy_lineup` (`dfs_strategy_id`, `dfs_race_lineup_id`),
  KEY `idx_dfs_strategies_race_lineups_strategy_lineup` (`dfs_strategy_id`, `dfs_race_lineup_id`, `deleted_at`),
  KEY `idx_dfs_strategies_race_lineups_lineup_id` (`dfs_race_lineup_id`, `deleted_at`),
  CONSTRAINT `fk_dfs_strategies_race_lineups_dfs_strategy_id` FOREIGN KEY (`dfs_strategy_id`) REFERENCES `dfs_strategies` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dfs_strategies_race_lineups_dfs_race_lineup_id` FOREIGN KEY (`dfs_race_lineup_id`) REFERENCES `dfs_race_lineups` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Pivot linking DFS strategies to race lineups.';

INSERT INTO nascar.dfs_strategies_race_lineups (dfs_strategy_id, dfs_race_lineup_id)
SELECT ds.id, drl.id
FROM nascar.dfs_race_lineups drl
JOIN nascar.dfs_strategies ds
    ON ds.name = drl.strategy
    AND ds.deleted_at IS NULL
WHERE drl.deleted_at IS NULL
  AND NOT EXISTS (
      SELECT 1
      FROM nascar.dfs_strategies_race_lineups dsrl
      WHERE dsrl.dfs_strategy_id = ds.id
        AND dsrl.dfs_race_lineup_id = drl.id
        AND dsrl.deleted_at IS NULL
  );

-- New index before dropping the old one (InnoDB FK on race_id uses the composite index).
ALTER TABLE `dfs_race_lineups` ADD KEY `idx_dfs_race_lineups_dfs_race` (`dfs_id`, `race_id`, `deleted_at`);
ALTER TABLE `dfs_race_lineups` DROP INDEX `idx_dfs_race_lineups_dfs_race_strategy`;
ALTER TABLE `dfs_race_lineups` DROP COLUMN `strategy`;

CREATE VIEW `v_dfs_race_lineups_overview` AS
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
JOIN dfs_lineup_drivers dld USING (dfs_race_lineup_id);

CREATE VIEW `v_dfs_strategies_drivers_exposure` AS
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
    AND d.deleted_at IS NULL;
