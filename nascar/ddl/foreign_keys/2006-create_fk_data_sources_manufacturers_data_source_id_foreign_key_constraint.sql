ALTER TABLE `data_sources_manufacturers` ADD CONSTRAINT `fk_data_sources_manufacturers_data_source_id` FOREIGN KEY (`data_source_id`) REFERENCES `data_sources` (`id`) ON DELETE CASCADE;
