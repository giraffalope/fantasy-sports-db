DELIMITER //

CREATE PROCEDURE `nascar`.`agg_hist_weeks_track_types_stats`(
    IN `r_series_id` BIGINT UNSIGNED,
    IN `r_season_id` BIGINT UNSIGNED,
    IN `r_week_id` BIGINT UNSIGNED
)
COMMENT 'Aggregated historical statistics for a specific race week''s track types in the NASCAR series, including practices, qualifying, race results, as well as penalties and pitstops. It does not include the race week specified, but any data before the race week.'
BEGIN
    WITH 
    series AS (
        SELECT DISTINCT
            sr.id AS series_id
        FROM nascar.series sr
        WHERE sr.id = r_series_id
            AND sr.deleted_at IS NULL
    ),
    seasons AS (
        SELECT DISTINCT
            sr.series_id,
            ss.id AS season_id
        FROM nascar.seasons ss
        JOIN series sr USING (series_id)
        WHERE ss.deleted_at IS NULL
            AND ss.id = r_season_id
    ),
    current_week AS (
        SELECT DISTINCT
            sr.series_id,
            ss.id AS season_id,
            ss.year AS season_year,
            w.id AS week_id,
            w.number AS week_number,
            w.scheduled_start AS week_scheduled_start
        FROM nascar.weeks w
        JOIN seasons ss USING (season_id)
        JOIN series sr USING (series_id)
        WHERE w.deleted_at IS NULL
            AND w.number = r_week_id
    ),
    track_types_weeks AS (
        SELECT DISTINCT
            s.series_id,
            w.season_id,
            w.id AS week_id,
            w.track_id,
            trk.track_type_id
        FROM nascar.weeks w
        LEFT JOIN current_week cw USING (series_id)
        JOIN seasons s ON s.season_id = w.season_id
        JOIN nascar.tracks trk ON trk.id = w.track_id AND trk.deleted_at IS NULL
        JOIN nascar.track_types tt ON tt.id = trk.track_type_id AND tt.deleted_at IS NULL
        WHERE w.deleted_at IS NULL
            AND w.number < cw.week_number
            AND s.year <= cw.season_year
    )
    SELECT
        hws.series_id as series_id,
        hws.season_id as season_id,
        hws.week_id as week_id,
        hws.track_id as track_id,
        ttw.track_type_id as track_type_id,
        hws.race_id,
        hws.car_driver_id,
        hws.car_id,
        hws.manufacturer_id,
        hws.team_id,
        hws.driver_id,
        hws.race_start_position,
        hws.race_finish_position,
        hws.race_best_position,
        hws.race_worst_position,
        hws.race_average_position,
        hws.race_green_flag_passes,
        hws.race_green_flag_times_passed,
        hws.race_green_flag_pass_diff,
        hws.race_quality_passes,
        hws.race_quality_passes_pct,
        hws.race_total_fastest_laps,
        hws.race_total_fastest_laps_pct,
        hws.race_total_top_15_laps,
        hws.race_total_top_15_laps_pct,
        hws.race_total_laps_led,
        hws.race_total_laps_led_pct,
        hws.race_total_laps_completed,
        hws.race_total_laps_completed_pct,
        hws.race_driver_rating,
        hws.race_car_status,
        hws.race_avg_pitstop_crew_time,
        hws.race_avg_pitstop_driver_time,
        hws.race_total_pitstops,
        hws.race_total_penalties,
        hws.race_total_race_laps,
        hws.race_total_race_miles,
        hws.qualifying_finish_position,
        hws.qualifying_best_speed,
        hws.qualifying_best_time,
        hws.practice_total_min_finish_position,
        hws.practice_total_max_finish_position,
        hws.practice_total_avg_finish_position,
        hws.practice_total_min_best_speed,
        hws.practice_total_max_best_speed,
        hws.practice_total_avg_best_speed,
        hws.practice_total_min_best_time,
        hws.practice_total_max_best_time,
        hws.practice_total_avg_best_time,
        hws.practice_total_min_total_laps,
        hws.practice_total_max_total_laps,
        hws.practice_total_avg_total_laps,
        hws.practice_total_sum_total_laps,
        hws.practice_total_min_5_lap_average_time,
        hws.practice_total_max_5_lap_average_time,
        hws.practice_total_avg_5_lap_average_time,
        hws.practice_total_min_10_lap_average_time,
        hws.practice_total_max_10_lap_average_time,
        hws.practice_total_avg_10_lap_average_time,
        hws.practice_total_min_20_lap_average_time,
        hws.practice_total_max_20_lap_average_time,
        hws.practice_total_avg_20_lap_average_time,
        hws.practice_total_min_25_lap_average_time,
        hws.practice_total_max_25_lap_average_time,
        hws.practice_total_avg_25_lap_average_time,
        hws.practice_total_min_30_lap_average_time,
        hws.practice_total_max_30_lap_average_time,
        hws.practice_total_avg_30_lap_average_time,
        hws.practice_total_min_10_lap_average_speed,
        hws.practice_total_max_10_lap_average_speed,
        hws.practice_total_avg_10_lap_average_speed,
        hws.practice_total_min_10_lap_start,
        hws.practice_total_max_10_lap_start,
        hws.practice_total_avg_10_lap_start,
        hws.practice_total_min_10_lap_end,
        hws.practice_total_max_10_lap_end,
        hws.practice_total_avg_10_lap_end,
        hws.practice_final_finish_position,
        hws.practice_final_best_speed,
        hws.practice_final_best_time,
        hws.practice_final_total_laps,
        hws.practice_final_5_lap_average_time,
        hws.practice_final_10_lap_average_time,
        hws.practice_final_20_lap_average_time,
        hws.practice_final_25_lap_average_time,
        hws.practice_final_30_lap_average_time,
        hws.practice_final_10_lap_average_speed,
        hws.practice_final_10_lap_start,
        hws.practice_final_10_lap_end
    FROM track_types_weeks ttw
    JOIN nascar.hist_weeks_stats hws USING (series_id, season_id, week_id, track_id)
    WHERE hws.deleted_at IS NULL
    ;
END //

DELIMITER ;
