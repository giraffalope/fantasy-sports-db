ALTER TABLE `agg_week_prev_track_types_drivers_results` ADD UNIQUE KEY `unique_awpttdr_series_season_week_track_type_driver` (`series_id`,`season_id`,`week_id`,`track_type_id`,`driver_id`);
