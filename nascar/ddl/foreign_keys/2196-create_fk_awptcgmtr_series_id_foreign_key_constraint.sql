ALTER TABLE `agg_week_prev_track_cgm_teams_results` ADD CONSTRAINT `fk_awptcgmtr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
