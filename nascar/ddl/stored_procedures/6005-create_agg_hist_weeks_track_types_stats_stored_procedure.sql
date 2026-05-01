-- agg_hist_weeks_track_types_stats: stored procedure used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `agg_hist_weeks_track_types_stats`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agg_hist_weeks_track_types_stats`(
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
        hws.r_start_position,
        hws.r_finish_position,
        hws.r_best_position,
        hws.r_worst_position,
        hws.r_average_position,
        hws.r_green_flag_passes,
        hws.r_green_flag_times_passed,
        hws.r_green_flag_pass_diff,
        hws.r_quality_passes,
        hws.r_quality_passes_pct,
        hws.r_total_fastest_laps,
        hws.r_total_fastest_laps_pct,
        hws.r_total_top_15_laps,
        hws.r_total_top_15_laps_pct,
        hws.r_total_laps_led,
        hws.r_total_laps_led_pct,
        hws.r_total_laps_completed,
        hws.r_total_laps_completed_pct,
        hws.r_driver_rating,
        hws.r_car_status,
        hws.r_avg_pitstop_crew_time,
        hws.r_avg_pitstop_driver_time,
        hws.r_total_pitstops,
        hws.r_total_penalties,
        hws.r_total_race_laps,
        hws.r_total_race_miles,
        hws.q_finish_position,
        hws.q_best_speed,
        hws.q_best_time,
        hws.pt_min_finish_position,
        hws.pt_max_finish_position,
        hws.pt_avg_finish_position,
        hws.pt_min_best_speed,
        hws.pt_max_best_speed,
        hws.pt_avg_best_speed,
        hws.pt_min_best_time,
        hws.pt_max_best_time,
        hws.pt_avg_best_time,
        hws.pt_min_total_laps,
        hws.pt_max_total_laps,
        hws.pt_avg_total_laps,
        hws.pt_sum_total_laps,
        hws.pt_min_5_lap_average_time,
        hws.pt_max_5_lap_average_time,
        hws.pt_avg_5_lap_average_time,
        hws.pt_min_10_lap_average_time,
        hws.pt_max_10_lap_average_time,
        hws.pt_avg_10_lap_average_time,
        hws.pt_min_20_lap_average_time,
        hws.pt_max_20_lap_average_time,
        hws.pt_avg_20_lap_average_time,
        hws.pt_min_25_lap_average_time,
        hws.pt_max_25_lap_average_time,
        hws.pt_avg_25_lap_average_time,
        hws.pt_min_30_lap_average_time,
        hws.pt_max_30_lap_average_time,
        hws.pt_avg_30_lap_average_time,
        hws.pt_min_10_lap_average_speed,
        hws.pt_max_10_lap_average_speed,
        hws.pt_avg_10_lap_average_speed,
        hws.pt_min_10_lap_start,
        hws.pt_max_10_lap_start,
        hws.pt_avg_10_lap_start,
        hws.pt_min_10_lap_end,
        hws.pt_max_10_lap_end,
        hws.pt_avg_10_lap_end,
        hws.pf_finish_position,
        hws.pf_best_speed,
        hws.pf_best_time,
        hws.pf_total_laps,
        hws.pf_5_lap_average_time,
        hws.pf_10_lap_average_time,
        hws.pf_20_lap_average_time,
        hws.pf_25_lap_average_time,
        hws.pf_30_lap_average_time,
        hws.pf_10_lap_average_speed,
        hws.pf_10_lap_start,
        hws.pf_10_lap_end
    FROM track_types_weeks ttw
    JOIN nascar.agg_week_results hws USING (series_id, season_id, week_id, track_id)
    WHERE hws.deleted_at IS NULL
    ;
END$$
DELIMITER ;
