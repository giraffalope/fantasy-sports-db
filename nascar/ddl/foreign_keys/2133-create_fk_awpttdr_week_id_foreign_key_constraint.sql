ALTER TABLE `agg_week_prev_track_types_drivers_results` ADD CONSTRAINT `fk_awpttdr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
