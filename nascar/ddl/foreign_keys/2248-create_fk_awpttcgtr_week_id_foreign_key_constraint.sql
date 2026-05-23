ALTER TABLE `agg_week_prev_track_types_cg_teams_results` ADD CONSTRAINT `fk_awpttcgtr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
