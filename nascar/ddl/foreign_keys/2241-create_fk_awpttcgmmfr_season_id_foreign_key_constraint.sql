ALTER TABLE `agg_week_prev_track_types_cgm_manufacturers_results` ADD CONSTRAINT `fk_awpttcgmmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
