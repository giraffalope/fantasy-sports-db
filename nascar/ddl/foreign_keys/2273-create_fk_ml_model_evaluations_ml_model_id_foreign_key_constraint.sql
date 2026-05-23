ALTER TABLE `ml_model_evaluations` ADD CONSTRAINT `fk_ml_model_evaluations_ml_model_id` FOREIGN KEY (`ml_model_id`) REFERENCES `ml_models` (`id`) ON DELETE CASCADE;
