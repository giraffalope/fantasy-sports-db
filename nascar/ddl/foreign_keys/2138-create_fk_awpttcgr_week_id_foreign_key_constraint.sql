ALTER TABLE `agg_week_prev_track_types_car_generations_results` ADD CONSTRAINT `fk_awpttcgr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
