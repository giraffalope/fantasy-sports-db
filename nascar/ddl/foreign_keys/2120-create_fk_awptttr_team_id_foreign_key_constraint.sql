ALTER TABLE `agg_week_prev_track_types_teams_results` ADD CONSTRAINT `fk_awptttr_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
