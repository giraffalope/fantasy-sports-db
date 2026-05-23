ALTER TABLE `agg_week_prev_track_cgm_drivers_results` ADD CONSTRAINT `fk_awptcgmdr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
