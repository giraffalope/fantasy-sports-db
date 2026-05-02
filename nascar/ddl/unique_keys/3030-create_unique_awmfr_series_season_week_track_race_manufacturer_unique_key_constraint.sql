ALTER TABLE `agg_week_manufacturers_results` ADD UNIQUE KEY `unique_awmfr_series_season_week_track_race_manufacturer` (`series_id`,`season_id`,`week_id`,`track_id`,`race_id`,`manufacturer_id`);
