ALTER TABLE `agg_week_prev_track_types_cgm_drivers_results` ADD CONSTRAINT `fk_awpttcgmdr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
