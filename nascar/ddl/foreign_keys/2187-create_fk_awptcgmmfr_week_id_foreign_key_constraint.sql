ALTER TABLE `agg_week_prev_track_cgm_manufacturers_results` ADD CONSTRAINT `fk_awptcgmmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
