CREATE TABLE `ml_labels` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots.',
  `car_driver_id` bigint(20) unsigned NOT NULL COMMENT 'Label grain matching ml_training_rows.',
  `targets_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Ground-truth post-race stats keyed by scoring-rule source fields.' CHECK (json_valid(`targets_json`)),
  `dfs_points` decimal(14,3) NOT NULL COMMENT 'DFS fantasy points derived from targets_json via scoring rules.',
  `dfs_points_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Component points JSON for debugging.' CHECK (`dfs_points_breakdown` IS NULL OR json_valid(`dfs_points_breakdown`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Post-race DFS labels per car_driver; join only for train/eval.';
