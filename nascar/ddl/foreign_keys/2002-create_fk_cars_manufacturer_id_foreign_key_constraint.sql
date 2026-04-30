ALTER TABLE `cars` ADD CONSTRAINT `fk_cars_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`id`) ON DELETE CASCADE;
