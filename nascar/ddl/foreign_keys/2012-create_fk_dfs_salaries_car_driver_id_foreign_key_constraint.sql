ALTER TABLE `dfs_salaries` ADD CONSTRAINT `fk_dfs_salaries_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
