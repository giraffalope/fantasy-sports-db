ALTER TABLE `agg_week_prev_track_types_manufacturers_results` ADD CONSTRAINT `fk_awpttmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
