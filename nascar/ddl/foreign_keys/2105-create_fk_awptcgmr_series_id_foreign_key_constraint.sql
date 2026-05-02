ALTER TABLE `agg_week_prev_track_car_generation_models_results` ADD CONSTRAINT `fk_awptcgmr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
