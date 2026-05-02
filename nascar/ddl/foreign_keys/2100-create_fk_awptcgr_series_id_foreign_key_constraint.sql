ALTER TABLE `agg_week_prev_track_car_generations_results` ADD CONSTRAINT `fk_awptcgr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
