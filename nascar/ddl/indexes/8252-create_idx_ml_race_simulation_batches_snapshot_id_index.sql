ALTER TABLE `ml_race_simulation_batches` ADD KEY `idx_ml_race_simulation_batches_snapshot_id` (`ml_training_snapshot_id`, `deleted_at`);
