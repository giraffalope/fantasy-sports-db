ALTER TABLE `nascar`.`qualifying_results`
    ADD CONSTRAINT `fk_qualifying_results_qualifying_id` FOREIGN KEY (`qualifying_id`) REFERENCES `nascar`.`qualifyings`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_qualifying_results_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE;
