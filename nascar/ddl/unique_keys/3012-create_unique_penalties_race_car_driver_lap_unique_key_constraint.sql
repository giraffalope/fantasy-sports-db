ALTER TABLE `penalties` ADD UNIQUE KEY `unique_penalties_race_car_driver_lap` (`race_id`,`car_driver_id`,`lap`);
