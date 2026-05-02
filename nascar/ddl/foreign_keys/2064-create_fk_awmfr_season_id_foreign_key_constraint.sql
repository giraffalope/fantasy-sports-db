ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
