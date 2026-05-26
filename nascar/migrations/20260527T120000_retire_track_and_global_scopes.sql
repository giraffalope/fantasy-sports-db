-- Soft-delete legacy ml_models rows whose model_scope is no longer trained.
-- Apply ONLY after one successful production retrain + predict cycle on the
-- new cohort design (nascar.cup.machine_learning.models). Cohort artifacts
-- under model_scope='track_type' do all the routing now.

UPDATE `ml_models`
SET `deleted_at` = UTC_TIMESTAMP()
WHERE `model_scope` IN ('track', 'global')
  AND `deleted_at` IS NULL;
