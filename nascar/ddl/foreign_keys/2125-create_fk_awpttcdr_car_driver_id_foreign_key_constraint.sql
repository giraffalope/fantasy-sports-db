ALTER TABLE `agg_week_prev_track_types_cars_drivers_results` ADD CONSTRAINT `fk_awpttcdr_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
