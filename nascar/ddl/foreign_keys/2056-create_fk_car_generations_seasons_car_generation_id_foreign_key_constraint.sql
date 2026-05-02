ALTER TABLE `car_generations_seasons` ADD CONSTRAINT `fk_car_generations_seasons_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
