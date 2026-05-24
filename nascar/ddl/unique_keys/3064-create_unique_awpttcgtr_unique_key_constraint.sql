ALTER TABLE `agg_week_prev_track_types_cg_teams_results` ADD UNIQUE KEY `unique_awpttcgtr_sswtt_team_cgen` (`series_id`,`season_id`,`week_id`,`track_type_id`,`team_id`,`car_generation_id`);
