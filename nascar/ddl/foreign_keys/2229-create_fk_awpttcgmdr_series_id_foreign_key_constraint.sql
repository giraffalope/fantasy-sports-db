ALTER TABLE `agg_week_prev_track_types_cgm_drivers_results` ADD CONSTRAINT `fk_awpttcgmdr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
