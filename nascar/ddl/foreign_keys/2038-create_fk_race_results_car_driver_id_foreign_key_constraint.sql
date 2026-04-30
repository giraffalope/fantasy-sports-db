ALTER TABLE `race_results` ADD CONSTRAINT `fk_race_results_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
