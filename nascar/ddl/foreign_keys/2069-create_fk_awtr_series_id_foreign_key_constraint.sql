ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
