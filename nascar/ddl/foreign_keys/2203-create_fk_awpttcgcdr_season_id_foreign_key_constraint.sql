ALTER TABLE `agg_week_prev_track_types_cg_cars_drivers_results` ADD CONSTRAINT `fk_awpttcgcdr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
