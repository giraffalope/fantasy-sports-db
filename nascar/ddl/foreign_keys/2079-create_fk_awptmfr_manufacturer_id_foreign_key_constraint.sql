ALTER TABLE `agg_week_prev_track_manufacturers_results` ADD CONSTRAINT `fk_awptmfr_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;
