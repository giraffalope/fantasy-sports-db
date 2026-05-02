ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;
