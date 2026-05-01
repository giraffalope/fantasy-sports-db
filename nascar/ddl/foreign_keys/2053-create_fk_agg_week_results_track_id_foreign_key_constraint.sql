ALTER TABLE `agg_week_results` ADD CONSTRAINT `fk_week_results_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
