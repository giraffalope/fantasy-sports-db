ALTER TABLE `agg_week_prev_track_car_generations_results` ADD UNIQUE KEY `unique_awptcgr_series_season_week_track_car_generation` (`series_id`,`season_id`,`week_id`,`track_id`,`car_generation_id`);
