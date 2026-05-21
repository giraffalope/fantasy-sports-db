-- sql_agg_week_results_query_generation: dynamic SELECT over agg_week_results via CTE filters.
-- JSON contract: top-level dimension keys (series, season, week, track, ...) each hold a filter object
-- or array of {"operator": "...", "id": <scalar|array>} objects. Example:
--   {"week": [{"id": 500, "operator": "less_than"}], "track": [{"id": [7], "operator": "in"}]}

DROP PROCEDURE IF EXISTS `sql_agg_week_results_query_generation`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sql_agg_week_results_query_generation`(
    p_json JSON,
    OUT p_query TEXT
)
    COMMENT 'SQL query generation for agg_week_results using nested dimension filter JSON.'
BEGIN
    DECLARE p_final_select_query TEXT;

    DECLARE p_series_predicate TEXT;
    DECLARE p_series_query TEXT;

    DECLARE p_season_predicate TEXT;
    DECLARE p_seasons_query TEXT;

    DECLARE p_car_generation_predicate TEXT;
    DECLARE p_car_generation_query TEXT;

    DECLARE p_car_generation_model_predicate TEXT;
    DECLARE p_car_generation_models_query TEXT;

    DECLARE p_week_predicate TEXT;
    DECLARE p_weeks_query TEXT;

    DECLARE p_track_predicate TEXT;
    DECLARE p_tracks_query TEXT;

    DECLARE p_race_predicate TEXT;
    DECLARE p_races_query TEXT;

    DECLARE p_team_predicate TEXT;
    DECLARE p_teams_query TEXT;

    DECLARE p_driver_predicate TEXT;
    DECLARE p_drivers_query TEXT;

    DECLARE p_track_type_predicate TEXT;
    DECLARE p_track_types_query TEXT;

    DECLARE p_car_driver_predicate TEXT;
    DECLARE p_car_drivers_query TEXT;

    DECLARE p_car_predicate TEXT;
    DECLARE p_cars_query TEXT;

    SET p_series_predicate = nascar.sql_build_dimension_predicate(p_json, 'series', 'sr.id');

    SET p_series_query = CONCAT(
        'series AS (\n',
        '\tSELECT sr.id AS series_id\n',
        '\tFROM nascar.series sr\n',
        '\tWHERE sr.deleted_at IS NULL\n',
        '\t\tAND ', p_series_predicate, '\n',
        ')'
    );

    SET p_season_predicate = nascar.sql_build_dimension_predicate(p_json, 'season', 's.id');

    SET p_seasons_query = CONCAT(
        'seasons AS (\n',
        '\tSELECT DISTINCT sr.series_id, s.id AS season_id\n',
        '\tFROM series sr\n',
        '\tJOIN nascar.seasons s ON sr.series_id = s.series_id AND s.deleted_at IS NULL\n',
        '\tWHERE ', p_season_predicate, '\n',
        ')'
    );

    SET p_car_generation_predicate = nascar.sql_build_dimension_predicate(p_json, 'car_generation', 'cgs.car_generation_id');

    SET p_car_generation_query = CONCAT(
        'car_generations AS (\n',
        '\tSELECT DISTINCT s.series_id, s.season_id, cgs.id as car_generations_seasons_id, cgs.car_generation_id\n',
        '\tFROM seasons s\n',
        '\tJOIN nascar.car_generations_seasons cgs ON s.season_id = cgs.season_id AND cgs.deleted_at IS NULL\n',
        '\tJOIN nascar.car_generations cg ON cgs.car_generation_id = cg.id AND cg.deleted_at IS NULL\n',
        '\tWHERE ', p_car_generation_predicate, '\n',
        ')'
    );

    SET p_car_generation_model_predicate = nascar.sql_build_dimension_predicate(p_json, 'car_generation_model', 'cgms.car_generation_model_id');

    SET p_car_generation_models_query = CONCAT(
        'car_generation_models AS (\n',
        '\tSELECT DISTINCT cgs.series_id, cgs.season_id, cgms.manufacturer_id, cgms.car_generation_model_id\n',
        '\tFROM car_generations cgs\n',
        '\tJOIN nascar.car_generation_models_seasons cgms ON cgs.car_generations_seasons_id = cgms.car_generations_seasons_id AND cgms.deleted_at IS NULL\n',
        '\tJOIN nascar.car_generation_models cgm ON cgms.car_generation_model_id = cgm.id AND cgm.deleted_at IS NULL\n',
        '\tWHERE ', p_car_generation_model_predicate, '\n',
        ')'
    );

    SET p_week_predicate = nascar.sql_build_dimension_predicate(p_json, 'week', 'w.id');

    SET p_weeks_query = CONCAT(
        'weeks AS (\n',
        '\tSELECT DISTINCT s.series_id, s.season_id, w.id AS week_id, w.track_id\n',
        '\tFROM seasons s\n',
        '\tJOIN nascar.weeks w ON s.season_id = w.season_id AND w.deleted_at IS NULL\n',
        '\tWHERE ', p_week_predicate, '\n',
        ')'
    );

    SET p_track_type_predicate = nascar.sql_build_dimension_predicate(p_json, 'track_type', 'tt.id');

    SET p_track_types_query = CONCAT(
        'track_types AS (\n',
        '\tSELECT DISTINCT tt.id AS track_type_id\n',
        '\tFROM nascar.track_types tt\n',
        '\tWHERE tt.deleted_at IS NULL\n',
        '\t\tAND ', p_track_type_predicate, '\n',
        ')'
    );

    SET p_track_predicate = nascar.sql_build_dimension_predicate(p_json, 'track', 't.id');

    SET p_tracks_query = CONCAT(
        'tracks AS (\n',
        '\tSELECT DISTINCT w.series_id, w.season_id, w.week_id, w.track_id\n',
        '\tFROM weeks w\n',
        '\tJOIN nascar.tracks t ON w.track_id = t.id AND t.deleted_at IS NULL\n',
        '\tJOIN nascar.tracks_track_types ttt ON ttt.track_id = t.id AND ttt.deleted_at IS NULL\n',
        '\tJOIN track_types tt ON ttt.track_type_id = tt.track_type_id\n',
        '\tWHERE ', p_track_predicate, '\n',
        ')'
    );

    SET p_race_predicate = nascar.sql_build_dimension_predicate(p_json, 'race', 'r.id');

    SET p_races_query = CONCAT(
        'races AS (\n',
        '\tSELECT DISTINCT w.series_id, w.season_id, w.week_id, w.track_id, r.id AS race_id\n',
        '\tFROM weeks w\n',
        '\tJOIN nascar.races r ON w.week_id = r.week_id AND r.deleted_at IS NULL\n',
        '\tWHERE ', p_race_predicate, '\n',
        ')'
    );

    SET p_team_predicate = nascar.sql_build_dimension_predicate(p_json, 'team', 't.id');

    SET p_teams_query = CONCAT(
        'teams AS (\n',
        '\tSELECT DISTINCT t.id AS team_id\n',
        '\tFROM nascar.teams t\n',
        '\tWHERE t.deleted_at IS NULL\n',
        '\t\tAND ', p_team_predicate, '\n',
        ')'
    );

    SET p_driver_predicate = nascar.sql_build_dimension_predicate(p_json, 'driver', 'd.id');

    SET p_drivers_query = CONCAT(
        'drivers AS (\n',
        '\tSELECT DISTINCT d.id AS driver_id\n',
        '\tFROM nascar.drivers d\n',
        '\tWHERE d.deleted_at IS NULL\n',
        '\t\tAND ', p_driver_predicate, '\n',
        ')'
    );

    SET p_car_driver_predicate = nascar.sql_build_dimension_predicate(p_json, 'car_driver', 'cd.id');

    SET p_car_drivers_query = CONCAT(
        'car_drivers AS (\n',
        '\tSELECT DISTINCT cd.id AS car_driver_id\n',
        '\tFROM nascar.cars_drivers cd\n',
        '\tWHERE cd.deleted_at IS NULL\n',
        '\t\tAND ', p_car_driver_predicate, '\n',
        ')'
    );

    SET p_car_predicate = nascar.sql_build_dimension_predicate(p_json, 'car', 'c.id');

    SET p_cars_query = CONCAT(
        'cars AS (\n',
        '\tSELECT DISTINCT c.id AS car_id\n',
        '\tFROM nascar.cars c\n',
        '\tWHERE c.deleted_at IS NULL\n',
        '\t\tAND ', p_car_predicate, '\n',
        ')'
    );

    SET p_final_select_query = CONCAT(
        'SELECT awr.*\n',
        'FROM nascar.agg_week_results awr\n',
        'JOIN series sr USING (series_id)\n',
        'JOIN seasons s USING (series_id, season_id)\n',
        'JOIN weeks w USING (series_id, season_id, week_id, track_id)\n',
        'JOIN races r USING (series_id, season_id, week_id, track_id, race_id)\n',
        'JOIN teams t USING (team_id)\n',
        'JOIN car_drivers cd USING (car_driver_id)\n',
        'JOIN drivers d USING (driver_id)\n',
        'JOIN cars c USING (car_id)\n',
        'JOIN car_generations cgs USING (series_id, season_id)\n',
        'JOIN car_generation_models cgms USING (series_id, season_id, manufacturer_id)\n',
        'WHERE awr.deleted_at IS NULL\n',
        'ORDER BY series_id, season_id, week_id, track_id, r_finish_position, r_start_position\n'
    );

    SET p_query = CONCAT(
        'WITH ',
        p_series_query, ',\n',
        p_seasons_query, ',\n',
        p_car_generation_query, ',\n',
        p_car_generation_models_query, ',\n',
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
