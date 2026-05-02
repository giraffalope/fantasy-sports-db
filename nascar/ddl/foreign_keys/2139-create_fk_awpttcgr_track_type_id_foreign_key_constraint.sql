ALTER TABLE `agg_week_prev_track_types_car_generations_results` ADD CONSTRAINT `fk_awpttcgr_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `track_types` (`id`) ON DELETE CASCADE;
