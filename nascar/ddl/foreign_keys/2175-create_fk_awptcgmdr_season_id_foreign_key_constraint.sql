ALTER TABLE `agg_week_prev_track_cgm_drivers_results` ADD CONSTRAINT `fk_awptcgmdr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
