ALTER TABLE `agg_week_prev_track_teams_results` ADD UNIQUE KEY `unique_awpttr_series_season_week_track_team` (`series_id`,`season_id`,`week_id`,`track_id`,`team_id`);
