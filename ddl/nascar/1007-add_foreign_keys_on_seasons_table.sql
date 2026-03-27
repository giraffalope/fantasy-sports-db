ALTER TABLE `nascar`.`seasons`
    ADD CONSTRAINT `fk_seasons_series_id` FOREIGN KEY (`series_id`) REFERENCES `nascar`.`series`(`id`) ON DELETE CASCADE;

