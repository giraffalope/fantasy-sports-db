ALTER TABLE `ml_training_rows` ADD CONSTRAINT `fk_ml_training_rows_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE CASCADE;
