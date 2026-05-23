ALTER TABLE `ml_predictions` ADD UNIQUE KEY `unique_ml_predictions_model_snapshot_car_driver` (`ml_model_id`,`ml_training_snapshot_id`,`car_driver_id`);
