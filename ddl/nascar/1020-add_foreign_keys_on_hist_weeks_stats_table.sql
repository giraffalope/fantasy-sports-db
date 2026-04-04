ALTER TABLE `nascar`.`hist_weeks_stats`
    ADD CONSTRAINT `fk_hist_weeks_stats_series_id` FOREIGN KEY (`series_id`) REFERENCES `nascar`.`series`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_season_id` FOREIGN KEY (`season_id`) REFERENCES `nascar`.`seasons`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_week_id` FOREIGN KEY (`week_id`) REFERENCES `nascar`.`weeks`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_track_id` FOREIGN KEY (`track_id`) REFERENCES `nascar`.`tracks`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_race_id` FOREIGN KEY (`race_id`) REFERENCES `nascar`.`races`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_car_driver_id` FOREIGN KEY (`car_driver_id`) REFERENCES `nascar`.`cars_drivers`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_car_id` FOREIGN KEY (`car_id`) REFERENCES `nascar`.`cars`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_manufacturer_id` FOREIGN KEY (`manufacturer_id`) REFERENCES `nascar`.`manufacturers`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_team_id` FOREIGN KEY (`team_id`) REFERENCES `nascar`.`teams`(`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_hist_weeks_stats_driver_id` FOREIGN KEY (`driver_id`) REFERENCES `nascar`.`drivers`(`id`) ON DELETE CASCADE;
