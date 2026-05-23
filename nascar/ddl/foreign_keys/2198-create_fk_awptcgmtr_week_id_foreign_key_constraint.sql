ALTER TABLE `agg_week_prev_track_cgm_teams_results` ADD CONSTRAINT `fk_awptcgmtr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
