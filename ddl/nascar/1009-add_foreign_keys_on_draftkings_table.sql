ALTER TABLE `nascar`.`draftkings`
    ADD CONSTRAINT `fk_draftkings_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE;

