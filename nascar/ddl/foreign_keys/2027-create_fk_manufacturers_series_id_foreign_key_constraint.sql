ALTER TABLE `manufacturers` ADD CONSTRAINT `fk_manufacturers_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
