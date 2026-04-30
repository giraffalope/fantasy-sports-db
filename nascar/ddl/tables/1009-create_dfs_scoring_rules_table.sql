CREATE TABLE `dfs_scoring_rules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `dfs_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to DFS provider.',
  `name` varchar(255) DEFAULT NULL COMMENT 'Canonical display name.',
  `version` int(10) unsigned NOT NULL COMMENT 'Version.',
  `rules` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Rules.' CHECK (json_valid(`rules`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Versioned scoring rules per DFS provider.';
