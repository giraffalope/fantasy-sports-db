ALTER TABLE `ml_predictions` ADD CONSTRAINT `fk_ml_predictions_ml_model_id` FOREIGN KEY (`ml_model_id`) REFERENCES `ml_models` (`id`) ON DELETE CASCADE;
