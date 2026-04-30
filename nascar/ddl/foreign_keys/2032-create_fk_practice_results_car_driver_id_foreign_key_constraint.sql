ALTER TABLE `practice_results` ADD CONSTRAINT `fk_practice_results_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
