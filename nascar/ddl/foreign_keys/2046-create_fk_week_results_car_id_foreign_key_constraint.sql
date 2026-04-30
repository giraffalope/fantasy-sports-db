ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_car_id` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;
