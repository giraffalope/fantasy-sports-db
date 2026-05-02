ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
