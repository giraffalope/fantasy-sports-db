ALTER TABLE `hist_weeks_track_types` ADD CONSTRAINT `fk_hist_weeks_track_types_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `track_types` (`id`) ON DELETE CASCADE;
