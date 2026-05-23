ALTER TABLE `agg_week_prev_track_cgm_manufacturers_results` ADD CONSTRAINT `fk_awptcgmmfr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
