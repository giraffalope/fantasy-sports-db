ALTER TABLE `nascar`.`cars`
    ADD CONSTRAINT `fk_cars_team_id` FOREIGN KEY (`team_id`) REFERENCES `nascar`.`teams`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_cars_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `nascar`.`manufacturers`(`id`) ON DELETE CASCADE;
