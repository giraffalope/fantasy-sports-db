ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
