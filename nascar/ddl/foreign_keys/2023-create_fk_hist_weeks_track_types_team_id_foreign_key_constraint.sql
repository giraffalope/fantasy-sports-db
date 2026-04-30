ALTER TABLE `hist_weeks_track_types` ADD CONSTRAINT `fk_hist_weeks_track_types_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
