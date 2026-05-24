ALTER TABLE `dfs_race_lineups_car_drivers` ADD CONSTRAINT `fk_dfs_race_lineups_car_drivers_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
