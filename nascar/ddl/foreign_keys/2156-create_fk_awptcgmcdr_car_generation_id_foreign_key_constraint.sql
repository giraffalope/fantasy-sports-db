ALTER TABLE `agg_week_prev_track_cgm_cars_drivers_results` ADD CONSTRAINT `fk_awptcgmcdr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
