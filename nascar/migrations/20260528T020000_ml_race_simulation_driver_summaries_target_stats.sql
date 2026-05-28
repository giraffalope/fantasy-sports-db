-- Per-target distribution summaries on Monte Carlo driver outputs.
--
-- Adds 22 columns to ``ml_race_simulation_driver_summaries``:
--
--   * 7 distribution stats (mean / std / min / p05 / p50 / p95 / max) for
--     each of the three sampled targets: ``r_finish_position``,
--     ``r_total_fastest_laps``, ``r_total_laps_led``.
--   * ``dnf_pct`` -- per-driver DNF rate from the new MC Bernoulli draw
--     wired from the two-stage classifier's blended ``P_dnf``.
--
-- All 21 stat columns are ``DECIMAL(14,3) NOT NULL DEFAULT 0`` and
-- ``dnf_pct`` is ``DECIMAL(5,4) NOT NULL DEFAULT 0``. The default lets
-- the ALTER run on existing rows without a coordinated backfill -- the
-- next MC batch always overwrites every column for that driver via
-- ``executemany`` INSERT, and stale summaries are soft-deleted before
-- the new INSERT lands.
--
-- All ADD COLUMNs are idempotent on re-apply: each is gated on
-- ``information_schema.COLUMNS`` so partial re-applies (e.g. only some
-- columns were added manually) don't raise "duplicate column" errors.

-- ---------------------------------------------------------------------------
-- r_finish_position distribution stats
-- ---------------------------------------------------------------------------

SET @add_mean_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'mean_r_finish_position'
);
SET @ddl := IF(
  @add_mean_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `mean_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Mean simulated finish position (1 = winner; tail-permuted for DNFed iterations).''
       AFTER `max_dfs_points`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_std_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'std_r_finish_position'
);
SET @ddl := IF(
  @add_std_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `std_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Standard deviation of simulated finish position.''
       AFTER `mean_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_min_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'min_r_finish_position'
);
SET @ddl := IF(
  @add_min_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `min_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Best (lowest) simulated finish position.''
       AFTER `std_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p05_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p05_r_finish_position'
);
SET @ddl := IF(
  @add_p05_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p05_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''5th percentile simulated finish position (high-ceiling outcome).''
       AFTER `min_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p50_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p50_r_finish_position'
);
SET @ddl := IF(
  @add_p50_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p50_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Median simulated finish position.''
       AFTER `p05_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p95_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p95_r_finish_position'
);
SET @ddl := IF(
  @add_p95_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p95_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''95th percentile simulated finish position (worst-case bucket, includes DNFed tails).''
       AFTER `p50_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_max_finish := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'max_r_finish_position'
);
SET @ddl := IF(
  @add_max_finish = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `max_r_finish_position` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Worst (highest) simulated finish position.''
       AFTER `p95_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- r_total_fastest_laps distribution stats
-- ---------------------------------------------------------------------------

SET @add_mean_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'mean_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_mean_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `mean_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Mean simulated fastest-laps count (post-constraint; scaled by completion fraction for DNFed iterations).''
       AFTER `max_r_finish_position`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_std_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'std_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_std_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `std_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Standard deviation of simulated fastest-laps count.''
       AFTER `mean_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_min_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'min_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_min_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `min_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Minimum simulated fastest-laps count.''
       AFTER `std_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p05_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p05_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_p05_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p05_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''5th percentile simulated fastest-laps count.''
       AFTER `min_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p50_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p50_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_p50_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p50_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Median simulated fastest-laps count.''
       AFTER `p05_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p95_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p95_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_p95_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p95_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''95th percentile simulated fastest-laps count.''
       AFTER `p50_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_max_fl := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'max_r_total_fastest_laps'
);
SET @ddl := IF(
  @add_max_fl = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `max_r_total_fastest_laps` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Maximum simulated fastest-laps count.''
       AFTER `p95_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- r_total_laps_led distribution stats
-- ---------------------------------------------------------------------------

SET @add_mean_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'mean_r_total_laps_led'
);
SET @ddl := IF(
  @add_mean_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `mean_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Mean simulated laps-led count (post-constraint; scaled by completion fraction for DNFed iterations).''
       AFTER `max_r_total_fastest_laps`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_std_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'std_r_total_laps_led'
);
SET @ddl := IF(
  @add_std_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `std_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Standard deviation of simulated laps-led count.''
       AFTER `mean_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_min_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'min_r_total_laps_led'
);
SET @ddl := IF(
  @add_min_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `min_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Minimum simulated laps-led count.''
       AFTER `std_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p05_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p05_r_total_laps_led'
);
SET @ddl := IF(
  @add_p05_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p05_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''5th percentile simulated laps-led count.''
       AFTER `min_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p50_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p50_r_total_laps_led'
);
SET @ddl := IF(
  @add_p50_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p50_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Median simulated laps-led count.''
       AFTER `p05_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_p95_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'p95_r_total_laps_led'
);
SET @ddl := IF(
  @add_p95_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `p95_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''95th percentile simulated laps-led count.''
       AFTER `p50_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @add_max_ll := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'max_r_total_laps_led'
);
SET @ddl := IF(
  @add_max_ll = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `max_r_total_laps_led` DECIMAL(14,3) NOT NULL DEFAULT 0
       COMMENT ''Maximum simulated laps-led count.''
       AFTER `p95_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- dnf_pct -- mean of the new per-iteration Bernoulli(P_dnf) draw.
-- ---------------------------------------------------------------------------

SET @add_dnf_pct := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'ml_race_simulation_driver_summaries'
    AND COLUMN_NAME = 'dnf_pct'
);
SET @ddl := IF(
  @add_dnf_pct = 0,
  'ALTER TABLE `ml_race_simulation_driver_summaries`
     ADD COLUMN `dnf_pct` DECIMAL(5,4) NOT NULL DEFAULT 0
       COMMENT ''Fraction of simulated iterations where the driver DNFed; equals the per-driver Bernoulli(P_dnf) empirical mean. Zero when the two-stage DNF classifier was inactive for this snapshot.''
       AFTER `max_r_total_laps_led`',
  'SELECT 1'
);
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
