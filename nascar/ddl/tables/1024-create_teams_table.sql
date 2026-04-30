CREATE TABLE `teams` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `series_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to series.',
  `name` varchar(255) DEFAULT NULL COMMENT 'Canonical display name.',
  `description` text DEFAULT NULL COMMENT 'Human-readable description.',
  `image` text DEFAULT NULL COMMENT 'Optional image URL or path.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Canonical team records used in car metadata and reporting.';
