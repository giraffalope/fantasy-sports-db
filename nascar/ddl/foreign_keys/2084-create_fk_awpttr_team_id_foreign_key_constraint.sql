ALTER TABLE `agg_week_prev_track_teams_results` ADD CONSTRAINT `fk_awpttr_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
