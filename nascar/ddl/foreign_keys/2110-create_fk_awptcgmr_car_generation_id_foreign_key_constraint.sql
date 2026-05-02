ALTER TABLE `agg_week_prev_track_car_generation_models_results` ADD CONSTRAINT `fk_awptcgmr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
