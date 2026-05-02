ALTER TABLE `agg_week_prev_track_manufacturers_results` ADD UNIQUE KEY `unique_awptmfr_series_season_week_track_manufacturer` (`series_id`,`season_id`,`week_id`,`track_id`,`manufacturer_id`);
