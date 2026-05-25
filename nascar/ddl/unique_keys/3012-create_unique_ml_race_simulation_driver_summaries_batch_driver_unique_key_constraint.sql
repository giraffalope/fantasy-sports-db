ALTER TABLE `ml_race_simulation_driver_summaries` ADD UNIQUE KEY `unique_ml_race_simulation_driver_summaries_batch_driver` (`ml_race_simulation_batch_id`, `car_driver_id`);
