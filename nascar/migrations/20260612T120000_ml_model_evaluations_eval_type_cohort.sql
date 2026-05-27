-- Add 'cohort' to ml_model_evaluations.eval_type so per-(series, track_type)
-- holdout evaluation rows from include/nascar/ml/train_task.py
-- (_persist_trained_model + _train_cohort) can be persisted. The application
-- code has written eval_type='cohort' since the cohort refactor, but the
-- corresponding schema change was missed. Until this migration ships,
-- _insert_evaluation() raises MySQL 1265 "Data truncated for column"
-- under strict mode.
--
-- 'week' and 'global' are retained for backward compat with any historical
-- rows from the pre-cohort design; no current code writes them.
--
-- Idempotent: MODIFY COLUMN with the same final state is a no-op.

ALTER TABLE `ml_model_evaluations`
  MODIFY COLUMN `eval_type` ENUM('week','track','global','cohort') NOT NULL
    COMMENT 'Evaluation slice type. cohort = per-(series_id, track_type_id) holdout; track = single-track holdout; week/global retained for legacy rows.';

ALTER TABLE `ml_model_evaluations`
  MODIFY COLUMN `eval_key` BIGINT(20) UNSIGNED DEFAULT NULL
    COMMENT 'Identifier paired with eval_type: track_type_id for cohort, track_id for track, week_id for week; NULL for global.';
