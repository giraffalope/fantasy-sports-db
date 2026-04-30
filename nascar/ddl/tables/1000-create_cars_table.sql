CREATE TABLE `cars` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `team_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to team.',
  `manufacturer_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to manufacturer.',
  `number` varchar(255) NOT NULL COMMENT 'Domain number value (event or entity specific).',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Canonical car entries used across race-week events and driver assignments.';
