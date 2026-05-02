ALTER TABLE `car_generations_seasons` ADD CONSTRAINT `fk_car_generations_seasons_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
