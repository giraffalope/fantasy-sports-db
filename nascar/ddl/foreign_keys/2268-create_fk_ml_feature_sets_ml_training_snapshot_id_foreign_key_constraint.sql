ALTER TABLE `ml_feature_sets` ADD CONSTRAINT `fk_ml_feature_sets_ml_training_snapshot_id` FOREIGN KEY (`ml_training_snapshot_id`) REFERENCES `ml_training_snapshots` (`id`) ON DELETE SET NULL;
