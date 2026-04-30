CREATE TABLE `qualifying_results` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `qualifying_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to qualifying session.',
  `car_driver_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to car-driver pairing.',
  `finish_position` int(10) unsigned NOT NULL COMMENT 'Recorded finishing position.',
  `best_speed` decimal(8,3) unsigned DEFAULT NULL,
  `best_time` time(3) DEFAULT NULL COMMENT 'Best observed lap/session time metric.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Per-car-driver qualifying session performance metrics.';
