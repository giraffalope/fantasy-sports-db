ALTER TABLE `ml_training_snapshots` ADD CONSTRAINT `fk_ml_training_snapshots_series_id` FOREIGN KEY (`series_id`) REFERENCES `series` (`id`) ON DELETE CASCADE;
