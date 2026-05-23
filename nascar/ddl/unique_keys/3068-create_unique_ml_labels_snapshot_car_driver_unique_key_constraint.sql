ALTER TABLE `ml_labels` ADD UNIQUE KEY `unique_ml_labels_snapshot_car_driver` (`ml_training_snapshot_id`,`car_driver_id`);
