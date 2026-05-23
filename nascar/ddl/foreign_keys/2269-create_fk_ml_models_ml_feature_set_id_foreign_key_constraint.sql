ALTER TABLE `ml_models` ADD CONSTRAINT `fk_ml_models_ml_feature_set_id` FOREIGN KEY (`ml_feature_set_id`) REFERENCES `ml_feature_sets` (`id`) ON DELETE CASCADE;
