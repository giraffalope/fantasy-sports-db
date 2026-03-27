ALTER TABLE `nascar`.`practice_results`
    ADD CONSTRAINT `fk_practice_results_practice_id` FOREIGN KEY (`practice_id`) REFERENCES `nascar`.`practices`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_practice_results_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE;
