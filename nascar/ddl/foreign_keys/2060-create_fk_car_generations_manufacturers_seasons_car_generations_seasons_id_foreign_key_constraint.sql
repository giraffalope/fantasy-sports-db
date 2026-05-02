ALTER TABLE `car_generation_models_seasons` ADD CONSTRAINT `fk_cgms_cgs_id` FOREIGN KEY (`car_generations_seasons_id`) REFERENCES `car_generations_seasons` (`id`) ON DELETE CASCADE;
