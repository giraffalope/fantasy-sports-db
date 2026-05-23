ALTER TABLE `agg_week_prev_track_cg_cars_drivers_results` ADD CONSTRAINT `fk_awptcgcdr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
