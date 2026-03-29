ALTER TABLE `nascar`.`racing_reference_drivers`
    ADD CONSTRAINT `fk_drivers_racing_reference_drivers_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `nascar`.`drivers` (`id`) ON DELETE CASCADE;