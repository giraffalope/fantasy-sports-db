ALTER TABLE `agg_week_prev_track_cgm_teams_results` ADD CONSTRAINT `fk_awptcgmtr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
