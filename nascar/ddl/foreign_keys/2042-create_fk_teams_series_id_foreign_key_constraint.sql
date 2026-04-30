ALTER TABLE `teams` ADD CONSTRAINT `fk_teams_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
