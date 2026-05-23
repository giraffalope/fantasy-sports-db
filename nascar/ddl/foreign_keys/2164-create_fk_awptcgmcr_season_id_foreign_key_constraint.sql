ALTER TABLE `agg_week_prev_track_cgm_cars_results` ADD CONSTRAINT `fk_awptcgmcr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
