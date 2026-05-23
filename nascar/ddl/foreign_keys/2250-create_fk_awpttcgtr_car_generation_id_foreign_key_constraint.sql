ALTER TABLE `agg_week_prev_track_types_cg_teams_results` ADD CONSTRAINT `fk_awpttcgtr_car_generation_id` FOREIGN KEY (`car_generation_id`) REFERENCES `car_generations` (`id`) ON DELETE CASCADE;
