CREATE TABLE `ml_models` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_feature_set_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_feature_sets.',
  `algorithm` varchar(64) NOT NULL COMMENT 'Model family (xgboost, lightgbm, ...).',
  `hyperparams_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Hyperparameters JSON.' CHECK (`hyperparams_json` IS NULL OR json_valid(`hyperparams_json`)),
  `artifact_uri` varchar(512) DEFAULT NULL COMMENT 'Path/URI to serialized model artifact.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Trained model registry entry.';
