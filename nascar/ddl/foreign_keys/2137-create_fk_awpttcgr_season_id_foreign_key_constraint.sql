ALTER TABLE `agg_week_prev_track_types_car_generations_results` ADD CONSTRAINT `fk_awpttcgr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
