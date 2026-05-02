ALTER TABLE `agg_week_prev_track_drivers_results` ADD UNIQUE KEY `unique_awptdr_series_season_week_track_driver` (`series_id`,`season_id`,`week_id`,`track_id`,`driver_id`);
