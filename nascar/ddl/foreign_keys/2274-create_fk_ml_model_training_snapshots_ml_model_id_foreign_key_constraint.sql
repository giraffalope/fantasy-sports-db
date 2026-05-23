ALTER TABLE `ml_model_training_snapshots` ADD CONSTRAINT `fk_ml_model_training_snapshots_ml_model_id` FOREIGN KEY (`ml_model_id`) REFERENCES `ml_models` (`id`) ON DELETE CASCADE;
