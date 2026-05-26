CREATE TABLE `ml_models` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_feature_set_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_feature_sets.',
  `algorithm` varchar(64) NOT NULL COMMENT 'Model family (xgboost regression / xgboost classifier / lightgbm / etc.).',
  `model_kind` enum('regression','regression_clean','dnf_classifier','quantile') NOT NULL DEFAULT 'regression' COMMENT 'D3 role of this model row in the two-stage / quantile design. regression = legacy single-head fit on all rows; regression_clean = fit on the non-DNF subset (paired with a dnf_classifier sibling); dnf_classifier = binary r_is_dnf head; quantile = v3 quantile head (reserved).',
  `series_id` bigint(20) unsigned NOT NULL COMMENT 'Series this model is trained for (FK to nascar.series.id); routing never crosses series.',
  `model_scope` varchar(16) NOT NULL DEFAULT 'global' COMMENT 'Routing scope within a series: track, track_type, or global.',
  `track_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Track this model is specialized for (NULL unless model_scope = track).',
  `track_type_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Track type this model is specialized for (NULL unless model_scope = track_type).',
  `hyperparams_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Hyperparameters JSON.' CHECK (`hyperparams_json` IS NULL OR json_valid(`hyperparams_json`)),
  `artifact_uri` varchar(512) DEFAULT NULL COMMENT 'Path/URI to serialized model artifact.',
  `cohort_n_weeks` int(10) unsigned DEFAULT NULL COMMENT 'Distinct finished week_ids in the training cohort at fit time; NULL for legacy rows.',
  `train_target_mean` decimal(14,6) DEFAULT NULL COMMENT 'Mean of the per-row target label across the training set; used as the predict-time fallback when no usable cohort model exists for a secondary target. NULL for legacy rows.',
  `holdout_residual_quantiles` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'E1 cohort-level conformal interval store. JSON object {"q05", "q10", "q50", "q90", "q95"} of |y - yhat| on the holdout slice (regression heads) or |proba - label| (classifier head). Consumed by Monte Carlo (rank-coupled MC sizing per-driver σ) and predict-time interval reporting when FS_ML_INTERVAL_METHOD=conformal. NULL for legacy rows.' CHECK (`holdout_residual_quantiles` IS NULL OR json_valid(`holdout_residual_quantiles`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`),
  CONSTRAINT `chk_ml_models_scope_keys` CHECK (
    (`model_scope` = 'global' AND `track_id` IS NULL AND `track_type_id` IS NULL)
    OR (`model_scope` = 'track' AND `track_id` IS NOT NULL AND `track_type_id` IS NULL)
    OR (`model_scope` = 'track_type' AND `track_id` IS NULL AND `track_type_id` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Trained model registry entry. Keyed by series_id then per-track / per-track-type / global scope.';
