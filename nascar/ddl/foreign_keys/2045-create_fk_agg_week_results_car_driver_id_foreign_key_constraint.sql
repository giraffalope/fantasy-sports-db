ALTER TABLE `agg_week_results` ADD CONSTRAINT `fk_week_results_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
