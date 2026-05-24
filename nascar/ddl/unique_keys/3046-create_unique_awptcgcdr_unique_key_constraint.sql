ALTER TABLE `agg_week_prev_track_cg_cars_drivers_results` ADD UNIQUE KEY `unique_awptcgcdr_sswt_cd_cgen` (`series_id`,`season_id`,`week_id`,`track_id`,`car_driver_id`,`car_generation_id`);
