ALTER TABLE `nascar`.`data_sources_manufacturers`
    ADD CONSTRAINT `fk_data_sources_manufacturers_data_source_id` FOREIGN KEY (`data_source_id`) REFERENCES `nascar`.`data_sources` (`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_data_sources_manufacturers_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `nascar`.`manufacturers` (`id`) ON DELETE CASCADE;
