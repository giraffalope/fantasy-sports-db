ALTER TABLE `nascar`.`data_sources_drivers`
    ADD CONSTRAINT `fk_data_sources_drivers_data_source_id` FOREIGN KEY (`data_source_id`) REFERENCES `nascar`.`data_sources` (`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_data_sources_drivers_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `nascar`.`drivers` (`id`) ON DELETE CASCADE;