ALTER TABLE `agg_week_teams_results` ADD UNIQUE KEY `unique_awtr_series_season_week_track_race_team` (`series_id`,`season_id`,`week_id`,`track_id`,`race_id`,`team_id`);
