DROP PROCEDURE IF EXISTS `sql_agg_week_results_query_generation`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sql_agg_week_results_query_generation`(
    p_json JSON,
    OUT p_query TEXT
)
    COMMENT 'SQL query generation procedure based on the agg_week_results table.'
BEGIN
	DECLARE p_final_select_query TEXT;

    DECLARE p_series_id TEXT;
    DECLARE p_series_query TEXT;
    
    DECLARE p_season_id TEXT;
	DECLARE p_car_generation_id TEXT;
    DECLARE p_car_generation_model_id TEXT;
    DECLARE p_seasons_query TEXT;
    
    
	DECLARE p_week_id TEXT;
    DECLARE p_weeks_query TEXT;
    
	DECLARE p_track_id TEXT;
    DECLARE p_tracks_query TEXT;
    
	DECLARE p_race_id TEXT;
    DECLARE p_races_query TEXT;
    
	DECLARE p_team_id TEXT;
    DECLARE p_teams_query TEXT;
    
	DECLARE p_driver_id TEXT;
    DECLARE p_drivers_query TEXT;
    
	DECLARE p_track_type_id TEXT;
    DECLARE p_track_types_query TEXT;
    
	DECLARE p_car_driver_id TEXT;
    DECLARE p_car_drivers_query TEXT;
    
	DECLARE p_car_id TEXT;
    DECLARE p_cars_query TEXT;
    
	-- Build match clause for series_id
    SET p_series_id = nascar.sql_build_match_clause_integer(p_json, 'series_id');

    -- Build the series subquery
    SET p_series_query = CONCAT(
		'series AS (\n',
        '\tSELECT sr.id AS series_id\n',
        '\tFROM nascar.series sr\n',
        '\tWHERE sr.deleted_at IS NULL\n',
        '\t\tAND sr.id ', p_series_id, '\n',
        ')'
    );

    -- Build match clause for season_id
    SET p_season_id = nascar.sql_build_match_clause_integer(p_json, 'season_id');
    SET p_car_generation_id = nascar.sql_build_match_clause_integer(p_json, 'car_generation_id');
    SET p_car_generation_model_id = nascar.sql_build_match_clause_integer(p_json, 'car_generation_model_id');

    -- Build the seasons subquery
    SET p_seasons_query = CONCAT(
		'seasons AS (\n',
        '\tSELECT DISTINCT sr.series_id, s.id AS season_id, cgs.car_generation_id, cgms.car_generation_model_id\n',
        '\tFROM series sr\n',
        '\tJOIN nascar.seasons s ON sr.series_id = s.series_id AND s.deleted_at IS NULL\n',
        '\tJOIN nascar.car_generations_seasons cgs ON s.id = cgs.season_id AND cgs.deleted_at IS NULL\n',
		'\tJOIN nascar.car_generation_models_seasons cgms ON cgs.id = cgms.car_generations_seasons_id AND cgms.deleted_at IS NULL\n',
        '\tWHERE s.id ', p_season_id, '\n',
        '\t\tAND cgs.car_generation_id ', p_car_generation_id, '\n',
		'\t\tAND cgms.car_generation_model_id ', p_car_generation_model_id, '\n',
        ')'
    );
    
	-- Build match clause for week_id
    SET p_week_id = nascar.sql_build_match_clause_integer(p_json, 'week_id');

    -- Build the weeks subquery
    SET p_weeks_query = CONCAT(
		'weeks AS (\n',
        '\tSELECT DISTINCT s.series_id, s.season_id, s.car_generation_id, s.car_generation_model_id, w.id AS week_id, w.track_id\n',
        '\tFROM seasons s\n',
        '\tJOIN nascar.weeks w ON s.season_id = w.season_id AND w.deleted_at IS NULL\n',
        '\tWHERE w.id ', p_week_id, '\n',
        ')'
    );
    
	-- Build match clause for track_type_id
    SET p_track_type_id = nascar.sql_build_match_clause_integer(p_json, 'track_type_id');

    -- Build the track_types subquery
    SET p_track_types_query = CONCAT(
		'track_types AS (\n',
        '\tSELECT DISTINCT tt.id as track_type_id\n',
        '\tFROM nascar.track_types tt\n',
        '\tWHERE tt.deleted_at IS NULL\n',
        '\t\tAND tt.id ', p_track_type_id, '\n',
        ')'
    );
    
	-- Build match clause for track_id
    SET p_track_id = nascar.sql_build_match_clause_integer(p_json, 'track_id');

    -- Build the tracks subquery
    SET p_tracks_query = CONCAT(
		'tracks AS (\n',
        '\tSELECT DISTINCT w.series_id, w.season_id, w.car_generation_id, w.car_generation_model_id, w.week_id, w.track_id\n',
        '\tFROM weeks w\n',
        '\tJOIN nascar.tracks t ON w.track_id = t.id AND t.deleted_at IS NULL\n',
        '\tJOIN nascar.tracks_track_types ttt ON ttt.track_id = t.id AND ttt.deleted_at IS NULL\n',
        '\tJOIN track_types tt ON ttt.track_type_id = tt.track_type_id\n'
        '\tWHERE t.id ', p_track_id, '\n',
        ')'
    );
    
	-- Build match clause for race_id
    SET p_race_id = nascar.sql_build_match_clause_integer(p_json, 'race_id');

    -- Build the races subquery
    SET p_races_query = CONCAT(
		'races AS (\n',
        '\tSELECT DISTINCT t.series_id, t.season_id, t.car_generation_id, t.car_generation_model_id, t.week_id, t.track_id, r.id as race_id\n',
        '\tFROM tracks t\n',
        '\tJOIN nascar.races r ON t.week_id = r.week_id AND r.deleted_at IS NULL\n',
        '\tWHERE r.id ', p_race_id, '\n',
        ')'
    );
    
	-- Build match clause for team_id
    SET p_team_id = nascar.sql_build_match_clause_integer(p_json, 'team_id');

    -- Build the teams subquery
    SET p_teams_query = CONCAT(
		'teams AS (\n',
        '\tSELECT DISTINCT t.id as team_id\n',
        '\tFROM nascar.teams t\n',
        '\tWHERE t.deleted_at IS NULL\n',
        '\t\tAND t.id ', p_team_id, '\n',
        ')'
    );
    
	-- Build match clause for driver_id
    SET p_driver_id = nascar.sql_build_match_clause_integer(p_json, 'driver_id');

    -- Build the drivers subquery
    SET p_drivers_query = CONCAT(
		'drivers AS (\n',
        '\tSELECT DISTINCT d.id as driver_id\n',
        '\tFROM nascar.drivers d\n',
        '\tWHERE d.deleted_at IS NULL\n',
        '\t\tAND d.id ', p_driver_id, '\n',
        ')'
    );
    
	-- Build match clause for car_driver_id
    SET p_car_driver_id = nascar.sql_build_match_clause_integer(p_json, 'car_driver_id');

    -- Build the car_drivers subquery
    SET p_car_drivers_query = CONCAT(
		'car_drivers AS (\n',
        '\tSELECT DISTINCT cd.id as car_driver_id\n',
        '\tFROM nascar.cars_drivers cd\n',
        '\tWHERE cd.deleted_at IS NULL\n',
        '\t\tAND cd.id ', p_car_driver_id, '\n',
        ')'
    );
    
	-- Build match clause for car_id
    SET p_car_id = nascar.sql_build_match_clause_integer(p_json, 'car_id');

    -- Build the cars subquery
    SET p_cars_query = CONCAT(
		'cars AS (\n',
        '\tSELECT DISTINCT c.id as car_id\n',
        '\tFROM nascar.cars c\n',
        '\tWHERE c.deleted_at IS NULL\n',
        '\t\tAND c.id ', p_car_id, '\n',
        ')'
    );
    
    SET p_final_select_query = CONCAT(
		'SELECT awr.*\n',
        'FROM nascar.agg_week_results awr\n',
		'JOIN series sr USING (series_id)\n',
		'JOIN seasons s USING (series_id, season_id, car_generation_id, car_generation_model_id)\n',
		'JOIN weeks w USING (series_id, season_id, car_generation_id, car_generation_model_id, week_id, track_id)\n',
		'JOIN races r USING (series_id, season_id, car_generation_id, car_generation_model_id, week_id, track_id, race_id)\n',
		'JOIN teams t USING (team_id)\n',
		'JOIN car_drivers cd USING (car_driver_id)\n',
		'JOIN drivers d USING (driver_id)\n',
		'JOIN cars c USING (car_id)\n',
        'WHERE awr.deleted_at IS NULL\n',
        'ORDER BY series_id, season_id, week_id, track_id, r_finish_position, r_start_position\n'
    );

    -- Build final CTE-based query
    SET p_query = CONCAT(
        'WITH ', 
        p_series_query, ',\n',
        p_seasons_query, ',\n',
		p_weeks_query, ',\n',
		p_track_types_query, ',\n',
		p_tracks_query, ',\n',
		p_races_query, ',\n',
        p_teams_query, ',\n',
        p_drivers_query, ',\n',
        p_car_drivers_query, ',\n',
        p_cars_query, '\n',
        p_final_select_query, ';'
    );
END$$
DELIMITER ;   