ALTER TABLE `ml_training_rows` ADD CONSTRAINT `fk_ml_training_rows_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
