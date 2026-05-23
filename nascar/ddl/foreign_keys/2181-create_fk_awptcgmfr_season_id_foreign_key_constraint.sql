ALTER TABLE `agg_week_prev_track_cg_manufacturers_results` ADD CONSTRAINT `fk_awptcgmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
