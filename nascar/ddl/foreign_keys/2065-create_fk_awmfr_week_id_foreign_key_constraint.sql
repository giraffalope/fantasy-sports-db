ALTER TABLE `agg_week_manufacturers_results` ADD CONSTRAINT `fk_awmfr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
