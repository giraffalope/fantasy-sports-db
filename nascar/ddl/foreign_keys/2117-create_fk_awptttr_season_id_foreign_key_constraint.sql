ALTER TABLE `agg_week_prev_track_types_teams_results` ADD CONSTRAINT `fk_awptttr_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
