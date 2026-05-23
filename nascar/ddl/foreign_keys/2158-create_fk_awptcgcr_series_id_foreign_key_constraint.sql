ALTER TABLE `agg_week_prev_track_cg_cars_results` ADD CONSTRAINT `fk_awptcgcr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
