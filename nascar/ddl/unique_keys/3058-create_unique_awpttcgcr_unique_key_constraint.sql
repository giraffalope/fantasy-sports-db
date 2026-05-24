ALTER TABLE `agg_week_prev_track_types_cg_cars_results` ADD UNIQUE KEY `unique_awpttcgcr_sswtt_car_cgen` (`series_id`,`season_id`,`week_id`,`track_type_id`,`car_id`,`car_generation_id`);
