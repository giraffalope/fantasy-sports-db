ALTER TABLE `ml_training_snapshots` ADD CONSTRAINT `fk_ml_training_snapshots_season_id` FOREIGN KEY (`season_id`) REFERENCES `seasons` (`id`) ON DELETE CASCADE;
