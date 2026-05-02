ALTER TABLE `agg_week_prev_track_car_generations_results` ADD CONSTRAINT `fk_awptcgr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
