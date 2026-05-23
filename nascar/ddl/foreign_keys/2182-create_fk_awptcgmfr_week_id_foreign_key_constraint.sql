ALTER TABLE `agg_week_prev_track_cg_manufacturers_results` ADD CONSTRAINT `fk_awptcgmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
