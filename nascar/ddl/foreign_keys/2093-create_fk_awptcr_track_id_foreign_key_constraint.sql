ALTER TABLE `agg_week_prev_track_cars_results` ADD CONSTRAINT `fk_awptcr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
