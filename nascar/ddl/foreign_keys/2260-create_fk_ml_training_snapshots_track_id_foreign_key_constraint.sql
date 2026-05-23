ALTER TABLE `ml_training_snapshots` ADD CONSTRAINT `fk_ml_training_snapshots_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
