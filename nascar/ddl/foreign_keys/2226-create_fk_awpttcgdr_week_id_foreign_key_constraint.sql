ALTER TABLE `agg_week_prev_track_types_cg_drivers_results` ADD CONSTRAINT `fk_awpttcgdr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
