ALTER TABLE `agg_week_prev_track_types_cars_results` ADD CONSTRAINT `fk_awpttcr_car_id` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;
