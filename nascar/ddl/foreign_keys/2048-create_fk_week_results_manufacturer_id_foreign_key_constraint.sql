ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;
