ALTER TABLE `agg_week_teams_results` ADD CONSTRAINT `fk_awtr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
