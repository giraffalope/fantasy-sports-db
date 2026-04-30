ALTER TABLE `hist_weeks_track_types` ADD CONSTRAINT `fk_hist_weeks_track_types_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
