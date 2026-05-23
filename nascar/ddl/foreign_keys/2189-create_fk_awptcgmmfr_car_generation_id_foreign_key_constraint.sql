ALTER TABLE `agg_week_prev_track_cgm_manufacturers_results` ADD CONSTRAINT `fk_awptcgmmfr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
