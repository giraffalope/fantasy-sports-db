ALTER TABLE `agg_week_prev_track_car_generations_results` ADD CONSTRAINT `fk_awptcgr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
