ALTER TABLE `nascar`.`races`
    ADD CONSTRAINT `fk_races_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE;
