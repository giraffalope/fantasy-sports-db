ALTER TABLE `agg_week_prev_track_drivers_results` ADD CONSTRAINT `fk_awptdr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
