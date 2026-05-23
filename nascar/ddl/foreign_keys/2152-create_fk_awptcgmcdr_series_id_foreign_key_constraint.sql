ALTER TABLE `agg_week_prev_track_cgm_cars_drivers_results` ADD CONSTRAINT `fk_awptcgmcdr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
