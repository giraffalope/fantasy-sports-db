ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
