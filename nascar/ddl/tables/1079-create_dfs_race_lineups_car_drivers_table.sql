CREATE TABLE `dfs_race_lineups_car_drivers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `dfs_race_lineup_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to dfs_race_lineups.',
  `car_driver_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to car-driver pairing.',
  `dfs_driver_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Provider-specific DFS driver identifier.',
  `projected_points` decimal(14,2) unsigned NOT NULL COMMENT 'Projected DFS points for this driver on the lineup.',
  `salary` int(10) unsigned NOT NULL COMMENT 'DraftKings salary for this driver on the slate.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Drivers selected for a DFS race lineup.';
