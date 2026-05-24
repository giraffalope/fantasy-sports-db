ALTER TABLE `agg_week_prev_track_cg_teams_results` ADD UNIQUE KEY `unique_awptcgtr_sswt_team_cgen` (`series_id`,`season_id`,`week_id`,`track_id`,`team_id`,`car_generation_id`);
