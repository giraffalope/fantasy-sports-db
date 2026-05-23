ALTER TABLE `agg_week_prev_track_types_cg_cars_results` ADD CONSTRAINT `fk_awpttcgcr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
