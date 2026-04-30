CREATE TABLE `drivers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `first_name` varchar(255) DEFAULT NULL COMMENT 'First name.',
  `last_name` varchar(255) DEFAULT NULL COMMENT 'Last name.',
  `suffix` varchar(255) DEFAULT NULL COMMENT 'Suffix.',
  `description` text DEFAULT NULL COMMENT 'Human-readable description.',
  `image` text DEFAULT NULL COMMENT 'Optional image URL or path.',
  `date_of_birth` date DEFAULT NULL COMMENT 'Date of birth.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Canonical NASCAR driver records referenced by event and stats tables.';
