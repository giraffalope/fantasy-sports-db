-- Add kind column to distinguish training snapshots (with labels) from
-- prediction snapshots (pre-race, labels absent). Also widen the unique key
-- so train and predict snapshots can coexist for the same week.

ALTER TABLE `ml_training_snapshots`
    ADD COLUMN `kind` varchar(16) NOT NULL DEFAULT 'train' COMMENT 'Snapshot kind: train (finished race, labels present) or predict (pre-race, labels absent).'
    AFTER `grain`;

ALTER TABLE `ml_training_snapshots`
    DROP KEY `unique_ml_training_snapshots_series_week_grain_scoring`;

ALTER TABLE `ml_training_snapshots`
    ADD UNIQUE KEY `unique_ml_training_snapshots_series_week_grain_scoring` (`series_id`,`week_id`,`grain`,`kind`,`dfs_scoring_rules_id`);
