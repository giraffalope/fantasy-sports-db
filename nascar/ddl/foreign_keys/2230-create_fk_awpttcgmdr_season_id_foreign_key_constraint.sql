ALTER TABLE `agg_week_prev_track_types_cgm_drivers_results` ADD CONSTRAINT `fk_awpttcgmdr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
