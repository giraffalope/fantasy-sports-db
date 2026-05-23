ALTER TABLE `agg_week_prev_track_cg_cars_results` ADD CONSTRAINT `fk_awptcgcr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
