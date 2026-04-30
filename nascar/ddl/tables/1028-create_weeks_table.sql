CREATE TABLE `weeks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `season_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to season.',
  `track_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to track.',
  `number` tinyint(3) unsigned NOT NULL COMMENT 'Domain number value (event or entity specific).',
  `season_number` tinyint(3) unsigned DEFAULT NULL COMMENT 'Series week sequence within the season.',
  `race_name` varchar(255) NOT NULL COMMENT 'Official race name for the scheduled week.',
  `scheduled_start` varchar(255) NOT NULL COMMENT 'Scheduled event start timestamp.',
  `event_type` enum('REGULAR','CLASH','ALLSTAR','HEAT','OTHER') NOT NULL DEFAULT 'REGULAR',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Week-level NASCAR schedule and event metadata.';
