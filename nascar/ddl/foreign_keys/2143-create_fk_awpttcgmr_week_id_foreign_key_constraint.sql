ALTER TABLE `agg_week_prev_track_types_car_generation_models_results` ADD CONSTRAINT `fk_awpttcgmr_week_id` FOREIGN KEY (`week_id`) REFERENCES `weeks` (`id`) ON DELETE CASCADE;
