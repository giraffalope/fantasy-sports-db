ALTER TABLE `agg_week_prev_track_cg_cars_drivers_results` ADD CONSTRAINT `fk_awptcgcdr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
