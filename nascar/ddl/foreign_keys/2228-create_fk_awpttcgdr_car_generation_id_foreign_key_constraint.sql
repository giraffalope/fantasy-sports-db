ALTER TABLE `agg_week_prev_track_types_cg_drivers_results` ADD CONSTRAINT `fk_awpttcgdr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
