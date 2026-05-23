ALTER TABLE `agg_week_prev_track_types_cg_cars_results` ADD CONSTRAINT `fk_awpttcgcr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
