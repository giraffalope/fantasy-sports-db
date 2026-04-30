ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
