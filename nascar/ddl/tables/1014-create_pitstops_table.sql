CREATE TABLE `pitstops` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `race_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to race.',
  `car_driver_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to car-driver pairing.',
  `leader_lap` int(10) unsigned NOT NULL COMMENT 'Leader lap at time of pit stop.',
  `driver_lap` int(10) unsigned NOT NULL COMMENT 'Driver lap at time of pit stop.',
  `type` enum('FOUR_WHEEL_CHANGE','TWO_WHEEL_CHANGE_RIGHT','TWO_WHEEL_CHANGE_LEFT') NOT NULL,
  `crew_time` time(3) NOT NULL COMMENT 'Crew pit stop duration.',
  `driver_time` time(3) NOT NULL COMMENT 'Driver pit lane duration.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Race pit stop events and timing details.';
