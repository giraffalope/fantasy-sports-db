ALTER TABLE `nascar`.`hist_weeks_track_types`
    ADD CONSTRAINT `fk_hist_weeks_track_types_series_id` FOREIGN KEY (`series_id`) REFERENCES `nascar`.`series`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_season_id` FOREIGN KEY (`season_id`) REFERENCES `nascar`.`seasons`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_track_id` FOREIGN KEY (`track_id`) REFERENCES `nascar`.`tracks`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_track_type_id` FOREIGN KEY (`track_type_id`) REFERENCES `nascar`.`track_types`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_race_id` FOREIGN KEY (`race_id`) REFERENCES `nascar`.`races`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_car_id` FOREIGN KEY (`car_id`) REFERENCES `nascar`.`cars`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `nascar`.`manufacturers`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_team_id` FOREIGN KEY (`team_id`) REFERENCES `nascar`.`teams`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_track_types_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `nascar`.`drivers`(`id`) ON DELETE CASCADE;
