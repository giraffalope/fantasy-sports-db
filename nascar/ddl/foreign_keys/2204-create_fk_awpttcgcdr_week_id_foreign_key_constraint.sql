ALTER TABLE `agg_week_prev_track_types_cg_cars_drivers_results` ADD CONSTRAINT `fk_awpttcgcdr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
