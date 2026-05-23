ALTER TABLE `ml_labels` ADD CONSTRAINT `fk_ml_labels_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
