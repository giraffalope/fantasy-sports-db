ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
