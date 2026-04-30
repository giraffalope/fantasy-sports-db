ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
