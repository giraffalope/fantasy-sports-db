ALTER TABLE `agg_week_prev_track_cars_results` ADD UNIQUE KEY `unique_awptcr_series_season_week_track_car` (`series_id`,`season_id`,`week_id`,`track_id`,`car_id`);
