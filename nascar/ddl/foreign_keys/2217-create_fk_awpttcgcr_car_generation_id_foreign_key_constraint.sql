ALTER TABLE `agg_week_prev_track_types_cg_cars_results` ADD CONSTRAINT `fk_awpttcgcr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
