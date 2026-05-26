-- Add train_target_mean column to ml_models for the B3 predict-time fallback.
-- Canonical DDL: nascar/ddl/tables/1074-create_ml_models_table.sql.
-- Consumed by nascar.cup.machine_learning.models (predict_upcoming_week) when
-- a secondary target has no usable cohort model — predict averages the
-- per-cohort train_target_mean values instead of falling back to a hard 0.0.

SET @col_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_models'
    AND COLUMN_NAME = 'train_target_mean'
);

SET @ddl := IF(
  @col_exists = 0,
  'ALTER TABLE `ml_models` ADD COLUMN `train_target_mean` DECIMAL(14,6) DEFAULT NULL COMMENT ''Mean of the per-row target label across the training set; used as the predict-time fallback when no usable cohort model exists for a secondary target. NULL for legacy rows.'' AFTER `cohort_n_weeks`',
  'SELECT ''ml_models.train_target_mean already present; skipping'''
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
