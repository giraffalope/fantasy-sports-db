ALTER TABLE `nascar`.`dfs_salaries`
  ADD INDEX `idx_dfs_salaries_race_dfs_car_driver` (`race_id`, `dfs_id`, `car_driver_id`);

ALTER TABLE `nascar`.`pitstops`
  ADD INDEX `idx_pitstops_race_type_car_driver` (`race_id`, `type`, `car_driver_id`);

ALTER TABLE `nascar`.`penalties`
  ADD INDEX `idx_penalties_race_lap` (`race_id`, `lap`);
