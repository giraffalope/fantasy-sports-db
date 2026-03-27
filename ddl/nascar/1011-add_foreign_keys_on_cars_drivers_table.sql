ALTER TABLE `nascar`.`cars_drivers`
    ADD CONSTRAINT `fk_cars_drivers_car_id` FOREIGN KEY (`car_id`) REFERENCES `nascar`.`cars`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_cars_drivers_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `nascar`.`drivers`(`id`) ON DELETE CASCADE;
