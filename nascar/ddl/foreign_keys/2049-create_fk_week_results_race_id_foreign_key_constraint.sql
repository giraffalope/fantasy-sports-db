ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
