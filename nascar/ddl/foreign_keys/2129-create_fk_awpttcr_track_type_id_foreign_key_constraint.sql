ALTER TABLE `agg_week_prev_track_types_cars_results` ADD CONSTRAINT `fk_awpttcr_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `track_types` (`id`) ON DELETE CASCADE;
