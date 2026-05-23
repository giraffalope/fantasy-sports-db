ALTER TABLE `ml_training_snapshots` ADD UNIQUE KEY `unique_ml_training_snapshots_series_week_grain_scoring` (`series_id`,`week_id`,`grain`,`dfs_scoring_rules_id`);
