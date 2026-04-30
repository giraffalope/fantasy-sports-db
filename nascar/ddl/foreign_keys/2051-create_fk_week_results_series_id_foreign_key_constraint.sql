ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
