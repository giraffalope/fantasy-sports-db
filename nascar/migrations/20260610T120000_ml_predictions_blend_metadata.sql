-- Phase E3 + E1: schema for blend lineage and per-cohort conformal intervals.
--
-- Two related additions:
--
--   1. ``ml_predictions.blend_metadata_json`` — per-row blend lineage written
--      by ``predict_upcoming_week_task``. Carries the track_type_ids,
--      contributing ml_model_ids, blend weights, requested vs used strategy,
--      cohort_n_weeks, drift_warnings (Phase E4), and conformal_intervals
--      (Phase E1 + E2). Downstream Monte Carlo / lineup audits read this
--      to reconstruct exactly which cohort models produced a given driver's
--      predicted DFS points.
--
--   2. ``ml_models.holdout_residual_quantiles`` — JSON object of holdout
--      residual quantiles ({"q05", "q10", "q50", "q90", "q95"}) computed at
--      train time per cohort model. Phase E2's rank-coupled Monte Carlo
--      reads this to size each driver's per-iteration σ from the cohort
--      that produced their predict-time blend (instead of the legacy
--      global MAE-derived σ).
--
-- Both ALTERs are idempotent on re-apply: each one is gated on
-- ``information_schema.COLUMNS`` so the migration can be run twice without
-- raising "duplicate column" errors. Canonical DDL:
--   * ``nascar/ddl/tables/1074-create_ml_models_table.sql``
--   * ``nascar/ddl/tables/1075-create_ml_predictions_table.sql``

SET @add_blend_metadata := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_predictions'
    AND COLUMN_NAME = 'blend_metadata_json'
);

SET @ddl := IF(
  @add_blend_metadata = 0,
  'ALTER TABLE `ml_predictions`
     ADD COLUMN `blend_metadata_json` LONGTEXT
       CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
       COMMENT ''E3 per-prediction blend lineage. JSON object with keys: track_type_ids (list[int]), model_ids (list[int]), model_kinds (list[str]), weights (list[float]), maes (list[float|null]), cohort_n_weeks (list[int]), blend_strategy_requested (str), blend_strategy_used (str), drift_warnings (list[{feature, train_mean, predict_mean, z, cohort_track_type_id}]), conformal_intervals (dict[target, {q05, q10, q50, q90, q95}]). Mirrors the resolved_scopes XCom emitted by predict_upcoming_week_task.''
       CHECK (`blend_metadata_json` IS NULL OR json_valid(`blend_metadata_json`))
       AFTER `predicted_dfs_points`',
  'SELECT ''ml_predictions.blend_metadata_json already present; skipping'''
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_residual_quantiles := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_models'
    AND COLUMN_NAME = 'holdout_residual_quantiles'
);

SET @ddl := IF(
  @add_residual_quantiles = 0,
  'ALTER TABLE `ml_models`
     ADD COLUMN `holdout_residual_quantiles` LONGTEXT
       CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
       COMMENT ''E1 cohort-level conformal interval store. JSON object {"q05", "q10", "q50", "q90", "q95"} of |y - yhat| on the holdout slice (regression heads) or |proba - label| (classifier head). Consumed by Monte Carlo (rank-coupled MC sizing per-driver σ) and predict-time interval reporting when FS_ML_INTERVAL_METHOD=conformal. NULL for legacy rows.''
       CHECK (`holdout_residual_quantiles` IS NULL OR json_valid(`holdout_residual_quantiles`))
       AFTER `train_target_mean`',
  'SELECT ''ml_models.holdout_residual_quantiles already present; skipping'''
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
