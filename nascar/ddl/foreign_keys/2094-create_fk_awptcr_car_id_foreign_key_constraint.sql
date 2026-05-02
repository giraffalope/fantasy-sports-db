ALTER TABLE `agg_week_prev_track_cars_results` ADD CONSTRAINT `fk_awptcr_car_id` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;
