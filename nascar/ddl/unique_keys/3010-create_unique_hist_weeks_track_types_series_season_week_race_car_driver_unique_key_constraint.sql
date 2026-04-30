ALTER TABLE `hist_weeks_track_types` ADD UNIQUE KEY `unique_hist_weeks_track_types_series_season_week_race_car_driver` (`series_id`,`season_id`,`week_id`,`race_id`,`car_driver_id`);
