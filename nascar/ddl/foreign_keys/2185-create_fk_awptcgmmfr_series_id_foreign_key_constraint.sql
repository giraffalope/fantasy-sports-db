ALTER TABLE `agg_week_prev_track_cgm_manufacturers_results` ADD CONSTRAINT `fk_awptcgmmfr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
