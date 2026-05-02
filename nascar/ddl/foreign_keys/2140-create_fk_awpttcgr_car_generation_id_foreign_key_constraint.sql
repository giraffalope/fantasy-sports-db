ALTER TABLE `agg_week_prev_track_types_car_generations_results` ADD CONSTRAINT `fk_awpttcgr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
