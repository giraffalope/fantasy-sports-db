ALTER TABLE `agg_week_prev_track_types_cgm_cars_results` ADD CONSTRAINT `fk_awpttcgmcr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
