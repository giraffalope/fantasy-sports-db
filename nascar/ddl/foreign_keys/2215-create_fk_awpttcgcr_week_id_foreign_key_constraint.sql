ALTER TABLE `agg_week_prev_track_types_cg_cars_results` ADD CONSTRAINT `fk_awpttcgcr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
