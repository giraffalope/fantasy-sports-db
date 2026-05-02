ALTER TABLE `agg_week_prev_track_cars_results` ADD CONSTRAINT `fk_awptcr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
