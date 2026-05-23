ALTER TABLE `ml_labels` ADD CONSTRAINT `fk_ml_labels_ml_training_snapshot_id` FOREIGN KEY (`ml_training_snapshot_id`) REFERENCES `ml_training_snapshots` (`id`) ON DELETE CASCADE;
