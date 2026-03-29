ALTER TABLE `nascar`.`racing_reference_manufacturers`
    ADD CONSTRAINT `fk_manufacturers_racing_reference_manufacturers_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `nascar`.`manufacturers` (`id`) ON DELETE CASCADE;
