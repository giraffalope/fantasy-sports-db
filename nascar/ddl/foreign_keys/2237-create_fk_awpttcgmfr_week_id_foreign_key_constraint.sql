ALTER TABLE `agg_week_prev_track_types_cg_manufacturers_results` ADD CONSTRAINT `fk_awpttcgmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
