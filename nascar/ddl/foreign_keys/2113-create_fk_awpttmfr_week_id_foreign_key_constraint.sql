ALTER TABLE `agg_week_prev_track_types_manufacturers_results` ADD CONSTRAINT `fk_awpttmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
