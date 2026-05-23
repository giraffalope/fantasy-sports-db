CREATE TABLE `ml_feature_sets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_training_snapshot_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Snapshot used for Boruta/SHAP when selection is week-specific.',
  `feature_schema_hash` char(64) DEFAULT NULL COMMENT 'Optional hash when feature set spans multiple snapshots.',
  `target_keys` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Label stat columns used when training this feature set.' CHECK (`target_keys` IS NULL OR json_valid(`target_keys`)),
  `selected_features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'JSON array of selected feature names.' CHECK (json_valid(`selected_features`)),
  `boruta_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Optional Boruta run metadata.' CHECK (`boruta_metadata` IS NULL OR json_valid(`boruta_metadata`)),
  `shap_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Optional SHAP summary metadata.' CHECK (`shap_metadata` IS NULL OR json_valid(`shap_metadata`)),
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Boruta/SHAP feature selection output for model training.';
