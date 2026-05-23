ALTER TABLE `agg_week_prev_track_cg_cars_drivers_results` ADD CONSTRAINT `fk_awptcgcdr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
