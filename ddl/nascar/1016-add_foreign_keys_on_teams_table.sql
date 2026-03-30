ALTER TABLE `nascar`.`teams`
    ADD CONSTRAINT `fk_teams_series_id` FOREIGN KEY (`series_id`) REFERENCES `nascar`.`series`(`id`) ON DELETE CASCADE;
