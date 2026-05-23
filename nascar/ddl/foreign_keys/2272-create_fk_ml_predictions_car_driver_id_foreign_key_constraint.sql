ALTER TABLE `ml_predictions` ADD CONSTRAINT `fk_ml_predictions_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
