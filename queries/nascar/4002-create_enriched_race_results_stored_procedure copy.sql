DELIMITER //

CREATE PROCEDURE `nascar`.`aggregate_week_statistics`(
    IN `r_series_name` VARCHAR(255),
    IN `r_start_year` INTEGER UNSIGNED,
    IN `r_start_week_number` TINYINT UNSIGNED,
    IN `r_end_year` INTEGER UNSIGNED,
    IN `r_end_week_number` TINYINT UNSIGNED
)
BEGIN
    WITH 
    series AS (
        SELECT 
            sr.id AS series_id
        FROM nascar.series sr
        WHERE sr.name = r_series_name
            AND sr.deleted_at IS NULL
    ),
    series_seasons AS (
        SELECT 
            s.id AS series_id,
            ss.id AS season_id
        FROM nascar.seasons ss
        JOIN series sr USING (series_id)
        WHERE ss.deleted_at IS NULL
            AND ss.year BETWEEN r_start_year AND r_end_year
    ),
    series_seasons_weeks AS (
        SELECT 
            ss.series_id AS series_id,
            ss.season_id AS season_id,
            w.id AS week_id,
            w.track_id AS track_id
        FROM nascar.weeks w
        JOIN series_seasons ss USING (series_id, season_id)
        WHERE w.deleted_at IS NULL
            AND w.number BETWEEN r_start_week_number AND r_end_week_number
    ),
    seasons AS (
        SELECT 
            ss.series_id AS series_id,
            ss.id AS season_id
        FROM series_seasons ss
        WHERE year = r_year -- TODO: determine if param or not
            AND ss.deleted_at IS NULL
    ),
    weeks AS (
        SELECT 
            ss.series_id AS series_id,
            ss.id AS season_id
            w.id AS week_id,
            w.track_id AS track_id
        FROM nascar.weeks w
        JOIN seasons ss USING (season_id)
        WHERE w.number = r_week_number
            AND w.deleted_at IS NULL
    ),
    tracks AS (
        SELECT 
            w.series_id AS series_id,
            w.season_id AS season_id,
            w.week_id AS week_id,
            t.id AS track_id,
            t.length AS track_length
        FROM nascar.tracks t
        JOIN weeks w USING (track_id)
        WHERE t.deleted_at IS NULL
    ),
    track_types AS (
        SELECT 
            w.series_id AS series_id,
            w.season_id AS season_id,
            w.week_id AS week_id,
            t.id AS track_id,
            tt.id AS track_type_id,
        FROM nascar.track_types tt
        JOIN tracks t USING (track_id)
        JOIN weeks w USING (track_id)
        WHERE tt.deleted_at IS NULL
    ),
    track_type_weeks AS (
        SELECT 
            ssw.series_id AS series_id,
            ssw.season_id AS season_id,
            ssw.week_id AS week_id,
            ssw.track_id AS track_id,
            tt.id AS track_type_id,
        FROM track_types tt
        JOIN series_seasons_weeks ssw USING (track_id, series_id, season_id, week_id)
    ),
    races AS (
        SELECT 
            w.series_id AS series_id,
            w.id AS season_id
            w.id AS week_id,
            w.track_id AS track_id,
            r.id as race_id
        FROM nascar.races r
        JOIN weeks w USING (week_id)
            AND r.deleted_at IS NULL
    ),
    track_type_races AS (
        SELECT             
            ssw.series_id AS series_id,
            ssw.season_id AS season_id,
            ssw.week_id AS week_id,
            ssw.track_id AS track_id,
            tt.id AS track_type_id,
            r.id AS race_id
        FROM track_type_weeks ttw
        JOIN nascar.races r USING (series_id, season_id, week_id, track_id)
        WHERE r.deleted_at IS NULL
    ),
    penalties AS (
        SELECT
            r.series_id AS series_id,
            r.season_id AS season_id,
            r.week_id AS week_id,
            r.track_id AS track_id,
            r.race_id AS race_id,
            pn.car_driver_id AS car_driver_id,
            count(*) AS total_penalties
        FROM nascar.penalties pn
        JOIN races r USING (race_id, car_driver_id)
        WHERE pn.deleted_at IS NULL
        GROUP BY ALL
    ),
    pitstops AS (
        SELECT
            r.series_id AS series_id,
            r.season_id AS season_id,
            r.week_id AS week_id,
            r.track_id AS track_id,
            r.race_id AS race_id,
            pt.car_driver_id AS car_driver_id,
            AVG(pt.crew_time) AS avg_pitstop_crew_time,
            AVG(pt.driver_time) AS avg_pitstop_driver_time,
            COUNT(*) AS total_pitstops
        FROM nascar.pitstops pt
        JOIN races r USING (race_id, car_driver_id)
        WHERE pt.deleted_at IS NULL
        GROUP BY ALL
    ),
    track_race_results AS (
        SELECT 
            r.series_id AS series_id,
            r.season_id AS season_id,
            r.week_id AS week_id,
            r.race_id AS race_id,
            r.track_id AS track_id,
            rr.id AS race_results_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            rr.start_position,
            rr.finish_position,
            rr.best_position,
            rr.worst_position,
            rr.average_position,
            rr.green_flag_passes,
            rr.green_flag_times_passed,
            rr.pass_diff as green_flag_pass_diff,
            rr.quality_passes,
            rr.quality_passes / rr.green_flag_passes AS quality_passes_pct,
            rr.total_fastest_laps,
            rr.total_fastest_laps / MAX(rr.total_laps_completed) OVER(PARTITION BY r.race_id) AS total_fastest_laps_pct,
            rr.total_top_15_laps,
            rr.total_top_15_laps / MAX(rr.total_laps_completed) OVER(PARTITION BY r.race_id) AS total_top_15_laps_pct,
            rr.total_laps_led,
            rr.total_laps_led / MAX(rr.total_laps_completed) OVER(PARTITION BY r.race_id) AS total_laps_led_pct,
            rr.total_laps_completed,
            rr.total_laps_completed / MAX(rr.total_laps_completed) OVER(PARTITION BY r.race_id) AS total_laps_completed_pct,
            rr.driver_rating,
            rr.car_status,
            pt.avg_pitstop_crew_time,
            pt.avg_pitstop_driver_time,
            pt.total_pitstops,
            pn.total_penalties,
            MAX(rr.total_laps_completed) OVER(PARTITION BY r.race_id) AS total_race_laps,
            MAX(rr.total_laps_completed) * tr.track_length OVER(PARTITION BY r.race_id) AS total_race_miles
        FROM nascar.race_results rr
        JOIN races r USING (race_id)
        JOIN nascar.cars_drivers cd ON cd.id = rr.car_driver_id AND cd.deleted_at IS NULL
        JOIN nascar.cars c ON c.id = cd.car_id AND c.deleted_at IS NULL
        JOIN nascar.manufacturers m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
        JOIN nascar.teams t ON t.id = c.team_id AND t.deleted_at IS NULL
        JOIN nascar.drivers d ON d.id = cd.driver_id AND cd.deleted_at IS NULL
        JOIN pitstops pt USING (series_id, season_id, week_id, track_id, race_id, car_driver_id)
        JOIN penalties pn USING (series_id, season_id, week_id, track_id, race_id, car_driver_id)
        JOIN tracks tr USING (series_id, season_id, week_id, track_id)
        WHERE rr.deleted_at IS NULL
    )
    SELECT *
    FROM race_results
    ORDER BY finish_position
    ;
END //

DELIMITER ;
