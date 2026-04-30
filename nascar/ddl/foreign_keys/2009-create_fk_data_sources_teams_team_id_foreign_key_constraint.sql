ALTER TABLE `data_sources_teams` ADD CONSTRAINT `fk_data_sources_teams_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
