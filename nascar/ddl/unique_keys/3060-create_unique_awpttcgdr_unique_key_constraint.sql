ALTER TABLE `agg_week_prev_track_types_cg_drivers_results` ADD UNIQUE KEY `unique_awpttcgdr_sswtt_drv_cgen` (`series_id`,`season_id`,`week_id`,`track_type_id`,`driver_id`,`car_generation_id`);
