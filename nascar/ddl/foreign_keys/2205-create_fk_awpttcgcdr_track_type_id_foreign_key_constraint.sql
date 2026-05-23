ALTER TABLE `agg_week_prev_track_types_cg_cars_drivers_results` ADD CONSTRAINT `fk_awpttcgcdr_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `track_types` (`id`) ON DELETE CASCADE;
