ALTER TABLE `agg_week_prev_track_manufacturers_results` ADD CONSTRAINT `fk_awptmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
