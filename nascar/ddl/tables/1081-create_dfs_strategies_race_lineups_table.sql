CREATE TABLE `dfs_strategies_race_lineups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `dfs_strategy_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to dfs_strategies.',
  `dfs_race_lineup_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to dfs_race_lineups.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Pivot linking DFS strategies to race lineups (many-to-many).';
