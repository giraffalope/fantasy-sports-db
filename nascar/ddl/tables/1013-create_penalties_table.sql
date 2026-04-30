CREATE TABLE `penalties` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `race_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to race.',
  `car_driver_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to car-driver pairing.',
  `lap` int(10) unsigned NOT NULL COMMENT 'Lap number for the event record.',
  `flag` enum('GREEN','YELLOW','WHITE','CHECKERED') DEFAULT NULL,
  `description` text DEFAULT NULL COMMENT 'Human-readable description.',
  `penalty` varchar(255) NOT NULL COMMENT 'Penalty type or short label.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Race penalty events ingested from source race feeds.';
