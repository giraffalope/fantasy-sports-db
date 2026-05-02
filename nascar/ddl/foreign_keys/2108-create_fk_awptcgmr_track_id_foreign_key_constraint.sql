ALTER TABLE `agg_week_prev_track_car_generation_models_results` ADD CONSTRAINT `fk_awptcgmr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
