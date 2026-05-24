ALTER TABLE `agg_week_prev_track_cg_drivers_results` ADD UNIQUE KEY `unique_awptcgdr_sswt_drv_cgen` (`series_id`,`season_id`,`week_id`,`track_id`,`driver_id`,`car_generation_id`);
