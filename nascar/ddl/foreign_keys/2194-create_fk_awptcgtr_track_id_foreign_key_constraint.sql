ALTER TABLE `agg_week_prev_track_cg_teams_results` ADD CONSTRAINT `fk_awptcgtr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
