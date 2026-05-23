ALTER TABLE `agg_week_prev_track_types_cgm_manufacturers_results` ADD CONSTRAINT `fk_awpttcgmmfr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
