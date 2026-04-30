ALTER TABLE `week_results` ADD CONSTRAINT `fk_week_results_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE CASCADE;
