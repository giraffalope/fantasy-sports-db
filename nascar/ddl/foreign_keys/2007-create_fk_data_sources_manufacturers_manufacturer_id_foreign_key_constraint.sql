ALTER TABLE `data_sources_manufacturers` ADD CONSTRAINT `fk_data_sources_manufacturers_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;
