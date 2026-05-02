ALTER TABLE `agg_week_prev_track_types_cars_results` ADD CONSTRAINT `fk_awpttcr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
