ALTER TABLE `car_generation_models_seasons` ADD CONSTRAINT `fk_cgms_car_generation_model_id` FOREIGN KEY (`car_generation_model_id`) REFERENCES `car_generation_models` (`id`) ON DELETE CASCADE;
