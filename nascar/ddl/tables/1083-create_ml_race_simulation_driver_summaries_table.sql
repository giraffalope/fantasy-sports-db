CREATE TABLE `ml_race_simulation_driver_summaries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_race_simulation_batch_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_race_simulation_batches.',
  `car_driver_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to cars_drivers for the simulated entry.',
  `n_simulations` int(10) unsigned NOT NULL COMMENT 'Draws aggregated into this summary; must match the batch n_simulations.',
  `mean_dfs_points` decimal(14,3) NOT NULL COMMENT 'Mean simulated DraftKings points.',
  `std_dfs_points` decimal(14,3) NOT NULL COMMENT 'Standard deviation of simulated DraftKings points.',
  `min_dfs_points` decimal(14,3) NOT NULL COMMENT 'Minimum simulated DraftKings points.',
  `p05_dfs_points` decimal(14,3) NOT NULL COMMENT '5th percentile of simulated DraftKings points.',
  `p50_dfs_points` decimal(14,3) NOT NULL COMMENT 'Median (50th percentile) simulated DraftKings points.',
  `p95_dfs_points` decimal(14,3) NOT NULL COMMENT '95th percentile of simulated DraftKings points.',
  `max_dfs_points` decimal(14,3) NOT NULL COMMENT 'Maximum simulated DraftKings points.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Per-driver Monte Carlo DFS-point distribution summaries for one batch.';
