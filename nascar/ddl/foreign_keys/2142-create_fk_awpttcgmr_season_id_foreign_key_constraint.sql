ALTER TABLE `agg_week_prev_track_types_car_generation_models_results` ADD CONSTRAINT `fk_awpttcgmr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
