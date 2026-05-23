ALTER TABLE `agg_week_prev_track_types_cg_cars_drivers_results` ADD CONSTRAINT `fk_awpttcgcdr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
