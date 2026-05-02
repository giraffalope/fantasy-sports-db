CREATE TABLE `car_generations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `name` varchar(255) NOT NULL COMMENT 'Canonical display name for the car generation.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Manufacturer car generation reference records.';
