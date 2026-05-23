ALTER TABLE `ml_predictions` ADD CONSTRAINT `fk_ml_predictions_ml_training_snapshot_id` FOREIGN KEY (`ml_training_snapshot_id`) REFERENCES `ml_training_snapshots` (`id`) ON DELETE CASCADE;
