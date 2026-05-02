ALTER TABLE `agg_week_prev_track_cars_drivers_results` ADD UNIQUE KEY `unique_awptcdr_series_season_week_track_car_driver` (`series_id`,`season_id`,`week_id`,`track_id`,`car_driver_id`);
