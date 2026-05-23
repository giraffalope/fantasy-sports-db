ALTER TABLE `agg_week_prev_track_cgm_manufacturers_results` ADD CONSTRAINT `fk_awptcgmmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
