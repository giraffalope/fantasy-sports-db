ALTER TABLE `agg_week_prev_track_types_teams_results` ADD UNIQUE KEY `unique_awptttr_series_season_week_track_type_team` (`series_id`,`season_id`,`week_id`,`track_type_id`,`team_id`);
