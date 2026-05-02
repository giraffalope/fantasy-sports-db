ALTER TABLE `agg_week_prev_track_cars_drivers_results` ADD CONSTRAINT `fk_awptcdr_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `cars_drivers` (`id`) ON DELETE CASCADE;
