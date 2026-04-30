ALTER TABLE `cars_drivers` ADD CONSTRAINT `fk_cars_drivers_car_id` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;
