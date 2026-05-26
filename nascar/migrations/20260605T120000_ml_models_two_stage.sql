-- D4: schema for the two-stage DNF model design (Phase D3).
--
-- Two new responsibilities:
--   1. ``ml_models.model_kind`` differentiates the regression-only legacy
--      models from the new ``regression_clean`` (trained on the non-DNF
--      subset) and ``dnf_classifier`` (binary head on ``r_is_dnf``) rows.
--      The ``quantile`` value is reserved for the v3 quantile-regression
--      heads called out in Phase E future work.
--   2. ``ml_models.algorithm`` widens its comment so the column documents
--      the multi-family taxonomy (regression / classifier / etc.) without
--      adding a second enum.
--   3. ``ml_model_evaluations.metric`` widens its comment to advertise the
--      new ``log_loss`` / ``auc`` (D3 holdout metrics) and the future
--      pinball quantile metrics referenced by Phase E.
--
-- All three ALTERs are idempotent on re-apply: MODIFY COLUMN is unconditional,
-- ADD COLUMN is gated on ``information_schema.COLUMNS`` so the migration can
-- be run twice without raising "duplicate column" errors.

ALTER TABLE `ml_models`
  MODIFY COLUMN `algorithm` VARCHAR(64) NOT NULL
    COMMENT 'Model family (xgboost regression / xgboost classifier / lightgbm / etc.).';

SET @add_model_kind := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_models'
    AND COLUMN_NAME = 'model_kind'
);

SET @ddl := IF(
  @add_model_kind = 0,
  'ALTER TABLE `ml_models`
     ADD COLUMN `model_kind` ENUM(''regression'', ''regression_clean'', ''dnf_classifier'', ''quantile'')
       NOT NULL DEFAULT ''regression''
       COMMENT ''D3 role of this model row in the two-stage / quantile design. regression = legacy single-head fit on all rows; regression_clean = fit on the non-DNF subset (paired with a dnf_classifier sibling); dnf_classifier = binary r_is_dnf head; quantile = v3 quantile head (reserved).''
       AFTER `algorithm`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `ml_model_evaluations`
  MODIFY COLUMN `metric` VARCHAR(32) NOT NULL
    COMMENT 'Metric name (mae, rmse, spearman, log_loss, auc, pinball_q05, pinball_q50, pinball_q95, dfs_points_mae, dfs_points_rmse, dfs_points_spearman, ...).';
