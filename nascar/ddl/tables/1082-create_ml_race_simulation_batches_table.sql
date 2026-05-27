CREATE TABLE `ml_race_simulation_batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots (kind=predict) the batch simulated.',
  `n_simulations` int(10) unsigned NOT NULL COMMENT 'Number of race draws per driver in this batch (minimum 1000).',
  `random_seed` bigint(20) NOT NULL COMMENT 'Seed used to construct the numpy.random.Generator for reproducibility.',
  `pipeline_version` varchar(64) DEFAULT NULL COMMENT 'Build identifier (git sha, semver) matching snapshot lineage.',
  `status` enum('completed','failed') NOT NULL DEFAULT 'completed' COMMENT 'Terminal state of the simulation run.',
  `joint_samples_artifact_uri` varchar(512) DEFAULT NULL COMMENT 'Absolute path to the per-batch joint-draws .npz sidecar (numpy savez_compressed; arrays: joint_dfs_points, car_driver_ids, meta). NULL when the artifact write degraded or for legacy batches; the lineup task then falls back to summary-derived independent samples.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Header per Monte Carlo race simulation run for one predict snapshot.';
