ALTER TABLE `agg_week_prev_track_types_cars_results` ADD UNIQUE KEY `unique_awpttcr_series_season_week_track_type_car` (`series_id`,`season_id`,`week_id`,`track_type_id`,`car_id`);
