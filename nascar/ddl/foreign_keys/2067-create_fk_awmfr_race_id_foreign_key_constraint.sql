ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
