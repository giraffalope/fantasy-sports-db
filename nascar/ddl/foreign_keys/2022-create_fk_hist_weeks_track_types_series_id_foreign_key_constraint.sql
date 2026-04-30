ALTER TABLE `hist_weeks_track_types` ADD CONSTRAINT `fk_hist_weeks_track_types_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
