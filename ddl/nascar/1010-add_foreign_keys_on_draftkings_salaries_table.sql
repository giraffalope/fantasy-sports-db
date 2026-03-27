ALTER TABLE `nascar`.`draftkings_salaries`
    ADD CONSTRAINT `fk_draftkings_salaries_draftkings_id` FOREIGN KEY (`draftkings_id`) REFERENCES `nascar`.`draftkings`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_draftkings_salaries_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE;
