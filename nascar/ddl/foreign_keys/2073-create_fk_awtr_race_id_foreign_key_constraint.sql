ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
