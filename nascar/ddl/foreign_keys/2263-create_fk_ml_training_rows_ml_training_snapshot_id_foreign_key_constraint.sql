ALTER TABLE `ml_training_rows` ADD CONSTRAINT `fk_ml_training_rows_ml_training_snapshot_id` FOREIGN KEY (`ml_training_snapshot_id`) REFERENCES `ml_training_snapshots` (`id`) ON DELETE CASCADE;
