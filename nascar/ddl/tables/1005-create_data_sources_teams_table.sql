CREATE TABLE `data_sources_teams` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `data_source_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to data source.',
  `team_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to team.',
  `name` varchar(255) NOT NULL COMMENT 'Canonical display name.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='External source to canonical team name mappings.';
