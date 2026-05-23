ALTER TABLE `agg_week_results` ADD CONSTRAINT `fk_week_results_car_generation_model_id` FOREIGN KEY (`car_generation_model_id`) REFERENCES `car_generation_models` (`id`) ON DELETE CASCADE;
