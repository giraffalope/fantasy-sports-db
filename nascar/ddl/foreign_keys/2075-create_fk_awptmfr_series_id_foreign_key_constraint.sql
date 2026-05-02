ALTER TABLE `agg_week_prev_track_manufacturers_results` ADD CONSTRAINT `fk_awptmfr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
