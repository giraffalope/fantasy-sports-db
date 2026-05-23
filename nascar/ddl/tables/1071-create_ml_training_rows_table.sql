CREATE TABLE `ml_training_rows` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots.',
  `car_driver_id` bigint(20) unsigned NOT NULL COMMENT 'Primary modeling grain for this snapshot.',
  `driver_id` bigint(20) unsigned NOT NULL COMMENT 'Driver for FanDuel lineup mapping.',
  `car_id` bigint(20) unsigned NOT NULL COMMENT 'Car for the race entry.',
  `team_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Team for the race entry.',
  `manufacturer_id` bigint(20) unsigned NOT NULL COMMENT 'Manufacturer for the race entry.',
  `car_generation_id` bigint(20) unsigned NOT NULL COMMENT 'Car generation for the race entry.',
  `car_generation_model_id` bigint(20) unsigned NOT NULL COMMENT 'Car generation model for the race entry.',
  `r_start_position` int(10) unsigned DEFAULT NULL COMMENT 'Pre-race starting position from agg_week_results.',
  `features_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Wide feature vector (numeric values only).' CHECK (json_valid(`features_json`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='One ML feature row per car_driver per snapshot (predict/backtest safe without labels).';
