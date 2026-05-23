ALTER TABLE `agg_week_prev_track_types_cgm_teams_results` ADD CONSTRAINT `fk_awpttcgmtr_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `track_types` (`id`) ON DELETE CASCADE;
