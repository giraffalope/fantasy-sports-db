ALTER TABLE `agg_week_prev_track_types_drivers_results` ADD CONSTRAINT `fk_awpttdr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
