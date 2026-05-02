ALTER TABLE `agg_week_prev_track_types_cars_results` ADD CONSTRAINT `fk_awpttcr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
