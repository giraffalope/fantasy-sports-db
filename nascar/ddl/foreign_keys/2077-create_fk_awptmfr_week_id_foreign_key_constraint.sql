ALTER TABLE `agg_week_prev_track_manufacturers_results` ADD CONSTRAINT `fk_awptmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
