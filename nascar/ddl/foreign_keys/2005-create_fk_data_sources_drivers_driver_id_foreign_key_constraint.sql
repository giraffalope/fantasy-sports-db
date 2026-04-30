ALTER TABLE `data_sources_drivers` ADD CONSTRAINT `fk_data_sources_drivers_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE CASCADE;
