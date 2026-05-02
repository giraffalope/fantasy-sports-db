ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
