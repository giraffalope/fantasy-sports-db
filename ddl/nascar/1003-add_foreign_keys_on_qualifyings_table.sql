ALTER TABLE `nascar`.`qualifyings`
    ADD CONSTRAINT `fk_qualifyings_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE;
