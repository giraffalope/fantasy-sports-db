CREATE TABLE `ml_model_evaluations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_model_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_models.',
  `eval_type` enum('week','track','global') NOT NULL COMMENT 'Evaluation slice type.',
  `eval_key` bigint(20) unsigned DEFAULT NULL COMMENT 'week_id or track_id when eval_type is week or track; NULL for global.',
  `metric` varchar(32) NOT NULL COMMENT 'Metric name (mae, rmse, spearman, log_loss, auc, pinball_q05, pinball_q50, pinball_q95, dfs_points_mae, dfs_points_rmse, dfs_points_spearman, ...).',
  `metric_value` decimal(14,6) NOT NULL COMMENT 'Metric value for the slice.',
  `sample_count` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Number of rows in the evaluation slice.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Aggregated model evaluation metrics by week, track, or globally.';
