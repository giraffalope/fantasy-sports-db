ALTER TABLE `race_results` ADD CONSTRAINT `fk_race_results_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
