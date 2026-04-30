ALTER TABLE `practice_results` ADD CONSTRAINT `fk_practice_results_practice_id` FOREIGN KEY (`practice_id`) REFERENCES `practices` (`id`) ON DELETE CASCADE;
