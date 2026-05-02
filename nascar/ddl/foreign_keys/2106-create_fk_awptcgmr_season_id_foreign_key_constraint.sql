ALTER TABLE `agg_week_prev_track_car_generation_models_results` ADD CONSTRAINT `fk_awptcgmr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
