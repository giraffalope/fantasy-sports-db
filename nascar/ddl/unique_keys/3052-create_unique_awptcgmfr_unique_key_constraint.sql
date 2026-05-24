ALTER TABLE `agg_week_prev_track_cg_manufacturers_results` ADD UNIQUE KEY `unique_awptcgmfr_sswt_mfr_cgen` (`series_id`,`season_id`,`week_id`,`track_id`,`manufacturer_id`,`car_generation_id`);
