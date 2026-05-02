ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
