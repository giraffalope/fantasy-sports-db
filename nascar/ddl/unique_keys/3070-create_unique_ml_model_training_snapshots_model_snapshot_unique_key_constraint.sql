ALTER TABLE `ml_model_training_snapshots` ADD UNIQUE KEY `unique_ml_model_training_snapshots_model_snapshot` (`ml_model_id`,`ml_training_snapshot_id`);
