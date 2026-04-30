ALTER TABLE `qualifying_results` ADD CONSTRAINT `fk_qualifying_results_qualifying_id` FOREIGN KEY (`qualifying_id`) REFERENCES `qualifyings` (`id`) ON DELETE CASCADE;
