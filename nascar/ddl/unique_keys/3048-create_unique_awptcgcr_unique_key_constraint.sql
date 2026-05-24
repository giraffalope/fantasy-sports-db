ALTER TABLE `agg_week_prev_track_cg_cars_results` ADD UNIQUE KEY `unique_awptcgcr_sswt_car_cgen` (`series_id`,`season_id`,`week_id`,`track_id`,`car_id`,`car_generation_id`);
