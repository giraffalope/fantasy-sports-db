ALTER TABLE `pitstops` ADD UNIQUE KEY `unique_pitstops_race_car_driver_leader_lap_driver_lap` (`race_id`,`car_driver_id`,`leader_lap`,`driver_lap`);
