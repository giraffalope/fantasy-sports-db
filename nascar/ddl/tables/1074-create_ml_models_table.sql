CREATE TABLE `ml_models` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_feature_set_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_feature_sets.',
  `algorithm` varchar(64) NOT NULL COMMENT 'Model family (xgboost, lightgbm, ...).',
  `series_id` bigint(20) unsigned NOT NULL COMMENT 'Series this model is trained for (FK to nascar.series.id); routing never crosses series.',
  `model_scope` varchar(16) NOT NULL DEFAULT 'global' COMMENT 'Routing scope within a series: track, track_type, or global.',
  `track_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Track this model is specialized for (NULL unless model_scope = track).',
  `track_type_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Track type this model is specialized for (NULL unless model_scope = track_type).',
  `hyperparams_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Hyperparameters JSON.' CHECK (`hyperparams_json` IS NULL OR json_valid(`hyperparams_json`)),
  `artifact_uri` varchar(512) DEFAULT NULL COMMENT 'Path/URI to serialized model artifact.',
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
