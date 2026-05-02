ALTER TABLE `agg_week_prev_track_types_drivers_results` ADD CONSTRAINT `fk_awpttdr_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `drivers` (`id`) ON DELETE CASCADE;
