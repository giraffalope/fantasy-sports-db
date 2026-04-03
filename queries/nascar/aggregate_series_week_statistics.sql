DELIMITER //

CREATE PROCEDURE `nascar`.`aggregate_series_week_statistics`(
    IN `r_series_name` VARCHAR(255),
    IN `r_start_year` INTEGER UNSIGNED,
    IN `r_start_week_number` TINYINT UNSIGNED,
    IN `r_end_year` INTEGER UNSIGNED,
    IN `r_end_week_number` TINYINT UNSIGNED
)
BEGIN
    WITH 
    series AS (
        SELECT DISTINCT
            sr.id AS series_id
        FROM nascar.series sr
        WHERE sr.name = r_series_name
            AND sr.deleted_at IS NULL
    ),
    series_seasons AS (
        SELECT DISTINCT
            s.id AS series_id,
            ss.id AS season_id
        FROM nascar.seasons ss
        JOIN series sr USING (series_id)
        WHERE ss.deleted_at IS NULL
            AND ss.year BETWEEN r_start_year AND r_end_year
    ),
    series_seasons_weeks AS (
        SELECT DISTINCT
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
        SELECT DISTINCT
            ss.series_id AS series_id,
            ss.id AS season_id
        FROM series_seasons ss
        WHERE year = r_year -- TODO: determine if param or not
            AND ss.deleted_at IS NULL
    ),
    weeks AS (
        SELECT DISTINCT
            ss.series_id AS series_id,
            ss.id AS season_id
            w.id AS week_id,
            w.track_id AS track_id
        FROM nascar.weeks w
        JOIN seasons ss USING (season_id)
        WHERE w.number = r_week_number
            AND w.deleted_at IS NULL
    ),
    track AS (
        SELECT DISTINCT
            w.series_id AS series_id,
            w.season_id AS season_id,
            w.week_id AS week_id,
            t.id AS track_id
        FROM nascar.tracks t
        JOIN weeks w USING (track_id)
        WHERE t.deleted_at IS NULL
    ),
    track_track_types AS (
        SELECT DISTINCT
            w.series_id AS series_id,
            w.season_id AS season_id,
            t.id AS track_id,
            tt.id AS track_type_id,
        FROM nascar.track_types tt
        RIGHT JOIN track t USING (track_id)
        JOIN weeks w USING (track_id)
        WHERE tt.deleted_at IS NULL
    ),
    track_track_types_weeks AS (
        SELECT DISTINCT
            ssw.series_id AS series_id,
            ssw.season_id AS season_id,
            ssw.week_id AS week_id,
            ttt.track_id AS track_id,
            ttt.track_type_id AS track_type_id,
        FROM track_track_types ttt
        RIGHT JOIN series_seasons_weeks ssw USING (track_id, series_id, season_id, week_id)
    ),
    track_track_types_weeks_practices AS (
        SELECT DISTINCT
            tttw.series_id AS series_id,
            tttw.season_id AS season_id,
            tttw.week_id AS week_id,
            tttw.track_id AS track_id,
            tttw.track_type_id AS track_type_id,
            p.id AS practice_id
            p.number AS practice_number
        FROM nascar.practices p
        JOIN track_track_types_weeks tttw USING (series_id, season_id, week_id, track_id)
        WHERE p.deleted_at IS NULL
    ),
    track_track_types_weeks_qualifyings AS (
        SELECT DISTINCT
            tttw.series_id AS series_id,
            tttw.season_id AS season_id,
            tttw.week_id AS week_id,
            tttw.track_id AS track_id,
            tttw.track_type_id AS track_type_id,
            q.id AS qualifying_id
        FROM nascar.qualifyings q
        JOIN track_track_types_weeks tttw USING (series_id, season_id, week_id, track_id)
        WHERE q.deleted_at IS NULL
    ),
    track_track_types_weeks_races AS (
        SELECT DISTINCT
            tttw.series_id AS series_id,
            tttw.season_id AS season_id,
            tttw.week_id AS week_id,
            tttw.track_id AS track_id,
            tttw.track_type_id AS track_type_id,
            r.id AS race_id
        FROM nascar.races r
        JOIN track_track_types_weeks tttw USING (series_id, season_id, week_id, track_id)
        WHERE r.deleted_at IS NULL
    ),
    track_track_types_weeks_races_penalties AS (
        SELECT
            r.series_id AS series_id,
            r.season_id AS season_id,
            r.week_id AS week_id,
            r.track_id AS track_id,
            r.track_type_id AS track_type_id,
            r.race_id AS race_id,
            pn.car_driver_id AS car_driver_id,
            count(*) AS total_penalties
        FROM nascar.penalties pn
        JOIN track_track_types_weeks_races r USING (race_id, car_driver_id)
        WHERE pn.deleted_at IS NULL
        GROUP BY ALL
    ),
    track_track_types_weeks_races_pitstops AS (
        SELECT
            r.series_id AS series_id,
            r.season_id AS season_id,
            r.week_id AS week_id,
            r.track_id AS track_id,
            r.track_type_id AS track_type_id,
            r.race_id AS race_id,
            pt.car_driver_id AS car_driver_id,
            AVG(pt.crew_time) AS avg_pitstop_crew_time,
            AVG(pt.driver_time) AS avg_pitstop_driver_time,
            COUNT(*) AS total_pitstops
        FROM nascar.pitstops pt
        JOIN track_track_types_weeks_races r USING (race_id, car_driver_id)
        WHERE pt.deleted_at IS NULL
        GROUP BY ALL
    ),
    aggregate_ids AS (
        SELECT DISTINCT
            r.series_id,
            r.season_id,
            r.week_id,
            r.track_id,
            r.track_type_id,
            r.race_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id
        FROM nascar.race_results rr
        JOIN track_type_races r USING (race_id)
    ),
    car_ids AS (
        SELECT DISTINCT car_id
        FROM aggregate_ids
    ),
    manufacturer_ids AS (
        SELECT DISTINCT manufacturer_id
        FROM aggregate_ids
    ),
    team_ids AS (
        SELECT DISTINCT team_id
        FROM aggregate_ids
    ),
    driver_ids AS (
        SELECT DISTINCT driver_id
        FROM aggregate_ids
    ),
    track_track_types_weeks_practices_results AS (
        SELECT DISTINCT
            tttwp.series_id AS series_id,
            tttwp.season_id AS season_id,
            tttwp.week_id AS week_id,
            tttwp.track_id AS track_id,
            tttwp.track_type_id AS track_type_id,
            tttwp.practice_id AS practice_id,
            tttwp.practice_number AS practice_number,
            pr.car_driver_id AS car_driver_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            pr.best_speed,
            pr.best_time,
            pr.total_laps,
            pr.5_lap_average_time,
            pr.10_lap_average_time,
            pr.20_lap_average_time,
            pr.25_lap_average_time,
            pr.30_lap_average_time,
            pr.10_lap_average_speed,
            pr.10_lap_start,
            pr.10_lap_end
        FROM nascar.practice_results pr
        JOIN track_track_types_weeks_practices tttwp USING (practice_id, car_driver_id)
        JOIN nascar.cars_drivers cd ON cd.id = pr.car_driver_id AND cd.deleted_at IS NULL
        JOIN nascar.cars c ON c.id = cd.car_id AND c.deleted_at IS NULL
        JOIN nascar.manufacturers m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
        JOIN nascar.teams t ON t.id = c.team_id AND t.deleted_at IS NULL
        JOIN nascar.drivers d ON d.id = cd.driver_id AND d.deleted_at IS NULL
        WHERE pr.deleted_at IS NULL
            AND pr.best_speed IS NOT NULL
            AND pr.best_time IS NOT NULL
            AND pr.total_laps IS NOT NULL
            AND pr.total_laps > 0
    ),
    track_track_types_weeks_practices_results_average AS (
        SELECT *
        FROM track_track_types_weeks_practices_results
    ),
    track_track_types_weeks_qualifying_results AS (
        SELECT DISTINCT
            tttwq.series_id AS series_id,
            tttwq.season_id AS season_id,
            tttwq.week_id AS week_id,
            tttwq.track_id AS track_id,
            tttwq.track_type_id AS track_type_id,
            tttwq.qualifying_id AS qualifying_id,
            pr.car_driver_id AS car_driver_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            qr.finish_position,
            qr.best_speed,
            qr.best_time
        FROM nascar.qualifying_results qr
        JOIN track_track_types_weeks_qualifyings tttwq USING (qualifying_id, car_driver_id)
        JOIN nascar.cars_drivers cd ON cd.id = qr.car_driver_id AND cd.deleted_at IS NULL
        JOIN nascar.cars c ON c.id = cd.car_id AND c.deleted_at IS NULL
        JOIN nascar.manufacturers m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
        JOIN nascar.teams t ON t.id = c.team_id AND t.deleted_at IS NULL
        JOIN nascar.drivers d ON d.id = cd.driver_id AND d.deleted_at IS NULL
        WHERE qr.deleted_at IS NULL
            AND qr.finish_position IS NOT NULL
            AND qr.best_speed IS NOT NULL
            AND qr.best_time IS NOT NULL
    ),
    track_track_types_weeks_race_results AS (
        SELECT
            tttwr.series_id AS series_id,
            tttwr.season_id AS season_id,
            tttwr.week_id AS week_id,
            tttwr.track_id AS track_id,
            tttwr.track_type_id AS track_type_id,
            tttwr.race_id AS race_id,
            pr.car_driver_id AS car_driver_id,
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
        JOIN track_track_types_weeks_races tttwr USING (race_id, car_driver_id)
        JOIN nascar.cars_drivers cd ON cd.id = rr.car_driver_id AND cd.deleted_at IS NULL
        JOIN nascar.cars c ON c.id = cd.car_id AND c.deleted_at IS NULL
        JOIN nascar.manufacturers m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
        JOIN nascar.teams t ON t.id = c.team_id AND t.deleted_at IS NULL
        JOIN nascar.drivers d ON d.id = cd.driver_id AND d.deleted_at IS NULL
        LEFT JOIN pitstops pt USING (series_id, season_id, week_id, track_id, race_id, car_driver_id)
        LEFT JOIN penalties pn USING (series_id, season_id, week_id, track_id, race_id, car_driver_id)
        WHERE rr.deleted_at IS NULL
            AND rr.finish_position IS NOT NULL
    ),
    race_results AS (
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
