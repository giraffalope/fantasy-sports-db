ALTER TABLE `agg_week_results` ADD CONSTRAINT `fk_week_results_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
