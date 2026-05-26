CREATE TABLE `ml_predictions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_model_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_models.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots for the scored week.',
  `car_driver_id` bigint(20) unsigned NOT NULL COMMENT 'Scored race entry.',
  `predicted_targets_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Model-predicted stats keyed like snapshot target_keys.' CHECK (json_valid(`predicted_targets_json`)),
  `predicted_dfs_points_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Component points from scoring rules on predicted stats.' CHECK (json_valid(`predicted_dfs_points_breakdown`)),
  `predicted_dfs_points` decimal(14,3) NOT NULL COMMENT 'Sum of predicted_dfs_points_breakdown for lineup ranking.',
  `blend_metadata_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'E3 per-prediction blend lineage. JSON object with keys: track_type_ids (list[int]), model_ids (list[int]), model_kinds (list[str]), weights (list[float]), maes (list[float|null]), cohort_n_weeks (list[int]), blend_strategy_requested (str), blend_strategy_used (str), drift_warnings (list[{feature, train_mean, predict_mean, z, cohort_track_type_id}]), conformal_intervals (dict[target, {q05, q10, q50, q90, q95}]). Mirrors the resolved_scopes XCom emitted by predict_upcoming_week_task.' CHECK (`blend_metadata_json` IS NULL OR json_valid(`blend_metadata_json`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Model predictions per car_driver per snapshot week.';
