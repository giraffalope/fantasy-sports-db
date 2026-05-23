ALTER TABLE `agg_week_prev_track_cg_teams_results` ADD CONSTRAINT `fk_awptcgtr_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
