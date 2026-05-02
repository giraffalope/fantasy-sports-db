ALTER TABLE `agg_week_prev_track_car_generations_results` ADD CONSTRAINT `fk_awptcgr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
