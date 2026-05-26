-- Add cohort lineage column to ml_models for the track_type cohort design.
-- Canonical DDL: nascar/ddl/tables/1074-create_ml_models_table.sql.
-- Consumed by nascar.cup.machine_learning.models (train + predict blend weighting).

SET @col_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_models'
    AND COLUMN_NAME = 'cohort_n_weeks'
);

SET @ddl := IF(
  @col_exists = 0,
  'ALTER TABLE `ml_models` ADD COLUMN `cohort_n_weeks` INT(10) UNSIGNED DEFAULT NULL COMMENT ''Distinct finished week_ids in the training cohort at fit time; NULL for legacy rows.'' AFTER `artifact_uri`',
  'SELECT ''ml_models.cohort_n_weeks already present; skipping''' 
);

PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
