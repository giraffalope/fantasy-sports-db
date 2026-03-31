ALTER TABLE `nascar`.`dfs_salaries`
    ADD CONSTRAINT `fk_dfs_salaries_dfs_id` FOREIGN KEY (`dfs_id`) REFERENCES `nascar`.`dfs`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_dfs_salaries_race_id` FOREIGN KEY (`race_id`) REFERENCES `nascar`.`races`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_dfs_salaries_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE;
