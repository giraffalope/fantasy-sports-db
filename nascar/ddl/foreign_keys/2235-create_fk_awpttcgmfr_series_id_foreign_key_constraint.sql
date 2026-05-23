ALTER TABLE `agg_week_prev_track_types_cg_manufacturers_results` ADD CONSTRAINT `fk_awpttcgmfr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
