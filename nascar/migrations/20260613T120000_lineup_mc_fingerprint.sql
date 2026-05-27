-- Portfolio-aware lineup selection (joint MC scoring).
--
-- Two responsibilities:
--
--   1. ``ml_race_simulation_batches`` gains ``joint_samples_artifact_uri`` so
--      the lineup task can locate the per-batch ``.npz`` sidecar that carries
--      the (n_drivers x n_simulations) DFS-point matrix. NULL is allowed for
--      legacy batches and for batches where the artifact write degraded; the
--      lineup task falls back to summary-derived independent samples in that
--      case (stamped ``mc_score_method='summary_fallback'``).
--
--   2. ``dfs_race_lineups`` gains an 8-column MC fingerprint so every chosen
--      lineup carries its lineup-level distribution stats plus the selector's
--      audit trail. Until this migration ships, lineups carry no MC numbers
--      and there is no in-DB evidence of which simulation produced which
--      lineup. The columns are nullable so historical rows (and the
--      summary-fallback path) can leave them unset.
--
-- All ALTERs are idempotent on re-apply: MODIFY COLUMN re-issues the same
-- final state as a no-op; ADD COLUMN is gated on
-- ``information_schema.COLUMNS`` so the migration can be run twice without
-- raising "duplicate column" errors.

SET @add_joint_uri := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_batches'
    AND COLUMN_NAME = 'joint_samples_artifact_uri'
);
SET @ddl := IF(
  @add_joint_uri = 0,
  'ALTER TABLE `ml_race_simulation_batches`
     ADD COLUMN `joint_samples_artifact_uri` VARCHAR(512) DEFAULT NULL
       COMMENT ''Absolute path to the per-batch joint-draws .npz sidecar (numpy savez_compressed; arrays: joint_dfs_points, car_driver_ids, meta). NULL when the artifact write degraded or for legacy batches; the lineup task then falls back to summary-derived independent samples.''
       AFTER `status`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ``dfs_race_lineups`` MC fingerprint columns. One ADD COLUMN per gated
-- block so partial re-applies (e.g. someone added a subset of columns
-- manually) remain idempotent.

SET @add_mc_mean := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_mean_dfs_points'
);
SET @ddl := IF(
  @add_mc_mean = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_mean_dfs_points` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''Lineup mean DFS points across joint MC draws (rank-coupling preserved; equals sum-of-driver-means within rounding when samples are independent).''
       AFTER `salary_total`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_mc_std := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_std_dfs_points'
);
SET @ddl := IF(
  @add_mc_std = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_std_dfs_points` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''Lineup std DFS points across joint MC draws; under E2 rank-coupling this is < sqrt(sum(driver_std^2)) because anti-correlated finishes attenuate cohort variance.''
       AFTER `mc_mean_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_mc_p10 := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_p10_dfs_points'
);
SET @ddl := IF(
  @add_mc_p10 = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_p10_dfs_points` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''Lineup 10th-percentile DFS points (high-floor metric used as the DOUBLE_UP cash-game objective).''
       AFTER `mc_std_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_mc_p50 := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_p50_dfs_points'
);
SET @ddl := IF(
  @add_mc_p50 = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_p50_dfs_points` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''Lineup median DFS points across joint MC draws (audit / leaderboard).''
       AFTER `mc_p10_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_mc_p90 := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_p90_dfs_points'
);
SET @ddl := IF(
  @add_mc_p90 = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_p90_dfs_points` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''Lineup 90th-percentile DFS points (high-ceiling metric used as the HIGH_RISK_REWARD GPP objective).''
       AFTER `mc_p50_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_mc_sharpe := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_sharpe'
);
SET @ddl := IF(
  @add_mc_sharpe = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_sharpe` DECIMAL(10,4) DEFAULT NULL
       COMMENT ''mc_mean_dfs_points / max(mc_std_dfs_points, 1e-6); higher means more certainty per unit of expected return.''
       AFTER `mc_p90_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_obj_value := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'objective_value'
);
SET @ddl := IF(
  @add_obj_value = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `objective_value` DECIMAL(14,3) DEFAULT NULL
       COMMENT ''The actual scalar the portfolio selector maximized for this row (varies by strategy: joint_p10 for DOUBLE_UP, joint_p90 for HIGH_RISK_REWARD, etc.).''
       AFTER `mc_sharpe`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_score_method := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'dfs_race_lineups'
    AND COLUMN_NAME = 'mc_score_method'
);
SET @ddl := IF(
  @add_score_method = 0,
  'ALTER TABLE `dfs_race_lineups`
     ADD COLUMN `mc_score_method` VARCHAR(32) DEFAULT NULL
       COMMENT ''Audit trail of how mc_* columns were computed: joint_p10 / joint_p50 / joint_p90 / joint_mean / joint_sharpe / summary_fallback (independent Gaussian from driver summaries when the joint .npz artifact is missing).''
       AFTER `objective_value`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
