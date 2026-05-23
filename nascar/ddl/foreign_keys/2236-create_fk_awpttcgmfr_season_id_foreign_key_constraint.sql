ALTER TABLE `agg_week_prev_track_types_cg_manufacturers_results` ADD CONSTRAINT `fk_awpttcgmfr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
