ALTER TABLE `agg_week_prev_track_cg_drivers_results` ADD CONSTRAINT `fk_awptcgdr_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
