CREATE TABLE `ml_model_training_snapshots` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `ml_model_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_models.',
  `ml_training_snapshot_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to ml_training_snapshots used in training.',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Junction of models to training snapshots used in fit.';
