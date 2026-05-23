ALTER TABLE `agg_week_prev_track_types_cgm_cars_drivers_results` ADD CONSTRAINT `fk_awpttcgmcdr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
