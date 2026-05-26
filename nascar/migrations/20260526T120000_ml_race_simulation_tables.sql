-- Monte Carlo race simulation tables: batch header + per-driver DFS-point summaries.
-- Canonical DDL: nascar/ddl/tables/1082-*.sql, 1083-*.sql plus FK/unique/index files.
-- Consumed by nascar.cup.machine_learning.models.monte_carlo and nascar.cup.dfs.lineup_generator.

CREATE TABLE IF NOT EXISTS `ml_race_simulation_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots (kind=predict) the batch simulated.',
  `n_simulations` int(10) unsigned NOT NULL COMMENT 'Number of race draws per driver in this batch (minimum 1000).',
  `random_seed` bigint(20) NOT NULL COMMENT 'Seed used to construct the numpy.random.Generator for reproducibility.',
  `pipeline_version` varchar(64) DEFAULT NULL COMMENT 'Build identifier (git sha, semver) matching snapshot lineage.',
  `status` enum('completed','failed') NOT NULL DEFAULT 'completed' COMMENT 'Terminal state of the simulation run.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`),
  KEY `idx_ml_race_simulation_batches_snapshot_id` (`ml_training_snapshot_id`, `deleted_at`),
  CONSTRAINT `fk_ml_race_simulation_batches_ml_training_snapshot_id` FOREIGN KEY (`ml_training_snapshot_id`) REFERENCES `ml_training_snapshots` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Header per Monte Carlo race simulation run for one predict snapshot.';

CREATE TABLE IF NOT EXISTS `ml_race_simulation_driver_summaries` (
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
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_ml_race_simulation_driver_summaries_batch_driver` (`ml_race_simulation_batch_id`, `car_driver_id`),
  KEY `idx_ml_race_simulation_driver_summaries_batch_id` (`ml_race_simulation_batch_id`, `deleted_at`),
  CONSTRAINT `fk_ml_race_simulation_driver_summaries_batch_id` FOREIGN KEY (`ml_race_simulation_batch_id`) REFERENCES `ml_race_simulation_batches` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ml_race_simulation_driver_summaries_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Per-driver Monte Carlo DFS-point distribution summaries for one batch.';
