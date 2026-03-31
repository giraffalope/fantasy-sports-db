ALTER TABLE `nascar`.`pitstops`
    ADD CONSTRAINT `fk_pitstops_race_id` FOREIGN KEY (`race_id`) REFERENCES `nascar`.`races`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_pitstops_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE;
