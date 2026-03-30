ALTER TABLE `nascar`.`manufacturers`
    ADD CONSTRAINT `fk_manufacturers_series_id` FOREIGN KEY (`series_id`) REFERENCES `nascar`.`series`(`id`) ON DELETE CASCADE;
