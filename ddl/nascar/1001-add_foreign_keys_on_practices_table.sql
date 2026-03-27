ALTER TABLE `nascar`.`practices`
    ADD CONSTRAINT `fk_practices_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE;
