DELIMITER //

CREATE PROCEDURE `nascar`.`agg_hist_weeks_track_cars_drivers_med_stats`(
    IN `r_series_id` INTEGER UNSIGNED,
    IN `r_season_id` INTEGER UNSIGNED,
    IN `r_week_id` TINYINT UNSIGNED
)
COMMENT 'Aggregate statistics for a specific race week in the NASCAR series, including practices, qualifying, race results, as well as penalties and pitstops.'
BEGIN
    SELECT
        r_series_id AS series_id,
        r_season_id AS season_id,
        r_week_id AS week_id,
        hws.track_id,
        hws.car_driver_id,
        ROUND(MEDIAN(hws.race_start_position), 3) OVER (PARTITION BY hws.race_start_position) as race_med_start_position,
        ROUND(MEDIAN(hws.race_finish_position), 3) OVER (PARTITION BY hws.race_finish_position) as race_med_finish_position,
        ROUND(MEDIAN(hws.race_best_position), 3) OVER (PARTITION BY hws.race_best_position) as race_med_best_position,
        ROUND(MEDIAN(hws.race_worst_position), 3) OVER (PARTITION BY hws.race_worst_position) as race_med_worst_position,
        ROUND(MEDIAN(hws.race_average_position), 3) OVER (PARTITION BY hws.race_average_position) as race_med_average_position,
        ROUND(MEDIAN(hws.race_green_flag_passes), 3) OVER (PARTITION BY hws.race_green_flag_passes) as race_med_green_flag_passes,
        ROUND(MEDIAN(hws.race_green_flag_times_passed), 3) OVER (PARTITION BY hws.race_green_flag_times_passed) as race_med_green_flag_times_passed,
        ROUND(MEDIAN(hws.race_green_flag_pass_diff), 3) OVER (PARTITION BY hws.race_green_flag_pass_diff) as race_med_green_flag_pass_diff,
        ROUND(MEDIAN(hws.race_quality_passes), 3) OVER (PARTITION BY hws.race_quality_passes) as race_med_quality_passes,
        ROUND(MEDIAN(hws.race_quality_passes_pct), 3) OVER (PARTITION BY hws.race_quality_passes_pct) as race_med_quality_passes_pct,
        ROUND(MEDIAN(hws.race_total_fastest_laps), 3) OVER (PARTITION BY hws.race_total_fastest_laps) as race_med_total_fastest_laps,
        ROUND(MEDIAN(hws.race_total_fastest_laps_pct), 3) OVER (PARTITION BY hws.race_total_fastest_laps_pct) as race_med_total_fastest_laps_pct,
        ROUND(MEDIAN(hws.race_total_top_15_laps), 3) OVER (PARTITION BY hws.race_total_top_15_laps) as race_med_total_top_15_laps,
        ROUND(MEDIAN(hws.race_total_top_15_laps_pct), 3) OVER (PARTITION BY hws.race_total_top_15_laps_pct) as race_med_total_top_15_laps_pct,
        ROUND(MEDIAN(hws.race_total_laps_led), 3) OVER (PARTITION BY hws.race_total_laps_led) as race_med_total_laps_led,
        ROUND(MEDIAN(hws.race_total_laps_led_pct), 3) OVER (PARTITION BY hws.race_total_laps_led_pct) as race_med_total_laps_led_pct,
        ROUND(MEDIAN(hws.race_total_laps_completed), 3) OVER (PARTITION BY hws.race_total_laps_completed) as race_med_total_laps_completed,
        ROUND(MEDIAN(hws.race_total_laps_completed_pct), 3) OVER (PARTITION BY hws.race_total_laps_completed_pct) as race_med_total_laps_completed_pct,
        ROUND(MEDIAN(hws.race_driver_rating), 3) OVER (PARTITION BY hws.race_driver_rating) as race_med_driver_rating,
        ROUND(MEDIAN(hws.race_avg_pitstop_crew_time), 3) OVER (PARTITION BY hws.race_avg_pitstop_crew_time) as race_med_pitstop_crew_time,
        ROUND(MEDIAN(hws.race_avg_pitstop_driver_time), 3) OVER (PARTITION BY hws.race_avg_pitstop_driver_time) as race_med_pitstop_driver_time,
        ROUND(MEDIAN(hws.race_total_pitstops), 3) OVER (PARTITION BY hws.race_total_pitstops) as race_med_total_pitstops,
        ROUND(MEDIAN(hws.race_total_penalties), 3) OVER (PARTITION BY hws.race_total_penalties) as race_med_total_penalties,
        ROUND(MEDIAN(hws.race_total_race_laps), 3) OVER (PARTITION BY hws.race_total_race_laps) as race_med_total_race_laps,
        ROUND(MEDIAN(hws.race_total_race_miles), 3) OVER (PARTITION BY hws.race_total_race_miles) as race_med_total_race_miles,
        ROUND(MEDIAN(hws.qualifying_finish_position), 3) OVER (PARTITION BY hws.qualifying_finish_position) as qualifying_med_finish_position,
        ROUND(MEDIAN(hws.qualifying_best_speed), 3) OVER (PARTITION BY hws.qualifying_best_speed) as qualifying_med_best_speed,
        ROUND(MEDIAN(hws.qualifying_best_time), 3) OVER (PARTITION BY hws.qualifying_best_time) as qualifying_med_best_time,
        ROUND(MEDIAN(hws.practice_total_min_finish_position), 3) OVER (PARTITION BY hws.practice_total_min_finish_position) as practice_total_med_min_finish_position,
        ROUND(MEDIAN(hws.practice_total_max_finish_position), 3) OVER (PARTITION BY hws.practice_total_max_finish_position) as practice_total_med_max_finish_position,
        ROUND(MEDIAN(hws.practice_total_avg_finish_position), 3) OVER (PARTITION BY hws.practice_total_avg_finish_position) as practice_total_med_avg_finish_position,
        ROUND(MEDIAN(hws.practice_total_min_best_speed), 3) OVER (PARTITION BY hws.practice_total_min_best_speed) as practice_total_med_min_best_speed,
        ROUND(MEDIAN(hws.practice_total_max_best_speed), 3) OVER (PARTITION BY hws.practice_total_max_best_speed) as practice_total_med_max_best_speed,
        ROUND(MEDIAN(hws.practice_total_avg_best_speed), 3) OVER (PARTITION BY hws.practice_total_avg_best_speed) as practice_total_med_best_speed,
        ROUND(MEDIAN(hws.practice_total_min_best_time), 3) OVER (PARTITION BY hws.practice_total_min_best_time) as practice_total_med_min_best_time,
        ROUND(MEDIAN(hws.practice_total_max_best_time), 3) OVER (PARTITION BY hws.practice_total_max_best_time) as practice_total_med_max_best_time,
        ROUND(MEDIAN(hws.practice_total_avg_best_time), 3) OVER (PARTITION BY hws.practice_total_avg_best_time) as practice_total_med_best_time,
        ROUND(MEDIAN(hws.practice_total_min_total_laps), 3) OVER (PARTITION BY hws.practice_total_min_total_laps) as practice_total_med_min_total_laps,
        ROUND(MEDIAN(hws.practice_total_max_total_laps), 3) OVER (PARTITION BY hws.practice_total_max_total_laps) as practice_total_med_max_total_laps,
        ROUND(MEDIAN(hws.practice_total_avg_total_laps), 3) OVER (PARTITION BY hws.practice_total_avg_total_laps) as practice_total_med_total_laps,
        ROUND(MEDIAN(hws.practice_total_sum_total_laps), 3) OVER (PARTITION BY hws.practice_total_sum_total_laps) as practice_total_med_sum_total_laps,
        ROUND(MEDIAN(hws.practice_total_min_5_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_min_5_lap_average_time) as practice_total_med_min_5_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_max_5_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_max_5_lap_average_time) as practice_total_med_max_5_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_avg_5_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_avg_5_lap_average_time) as practice_total_med_5_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_min_10_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_min_10_lap_average_time) as practice_total_med_min_10_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_max_10_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_max_10_lap_average_time) as practice_total_med_max_10_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_avg_10_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_avg_10_lap_average_time) as practice_total_med_10_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_min_20_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_min_20_lap_average_time) as practice_total_med_min_20_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_max_20_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_max_20_lap_average_time) as practice_total_med_max_20_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_avg_20_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_avg_20_lap_average_time) as practice_total_med_20_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_min_25_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_min_25_lap_average_time) as practice_total_med_min_25_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_max_25_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_max_25_lap_average_time) as practice_total_med_max_25_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_avg_25_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_avg_25_lap_average_time) as practice_total_med_25_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_min_30_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_min_30_lap_average_time) as practice_total_med_min_30_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_max_30_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_max_30_lap_average_time) as practice_total_med_max_30_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_avg_30_lap_average_time), 3) OVER (PARTITION BY hws.practice_total_avg_30_lap_average_time) as practice_total_med_30_lap_average_time,
        ROUND(MEDIAN(hws.practice_total_min_10_lap_average_speed), 3) OVER (PARTITION BY hws.practice_total_min_10_lap_average_speed) as practice_total_med_min_10_lap_average_speed,
        ROUND(MEDIAN(hws.practice_total_max_10_lap_average_speed), 3) OVER (PARTITION BY hws.practice_total_max_10_lap_average_speed) as practice_total_med_max_10_lap_average_speed,
        ROUND(MEDIAN(hws.practice_total_avg_10_lap_average_speed), 3) OVER (PARTITION BY hws.practice_total_avg_10_lap_average_speed) as practice_total_med_10_lap_average_speed,
        ROUND(MEDIAN(hws.practice_total_min_10_lap_start), 3) OVER (PARTITION BY hws.practice_total_min_10_lap_start) as practice_total_med_min_10_lap_start,
        ROUND(MEDIAN(hws.practice_total_max_10_lap_start), 3) OVER (PARTITION BY hws.practice_total_max_10_lap_start) as practice_total_med_max_10_lap_start,
        ROUND(MEDIAN(hws.practice_total_avg_10_lap_start), 3) OVER (PARTITION BY hws.practice_total_avg_10_lap_start) as practice_total_med_10_lap_start,
        ROUND(MEDIAN(hws.practice_total_min_10_lap_end), 3) OVER (PARTITION BY hws.practice_total_min_10_lap_end) as practice_total_med_min_10_lap_end,
        ROUND(MEDIAN(hws.practice_total_max_10_lap_end), 3) OVER (PARTITION BY hws.practice_total_max_10_lap_end) as practice_total_med_max_10_lap_end,
        ROUND(MEDIAN(hws.practice_total_avg_10_lap_end), 3) OVER (PARTITION BY hws.practice_total_avg_10_lap_end) as practice_total_med_10_lap_end,
        ROUND(MEDIAN(hws.practice_final_finish_position), 3) OVER (PARTITION BY hws.practice_final_finish_position) as practice_final_med_finish_position,
        ROUND(MEDIAN(hws.practice_final_best_speed), 3) OVER (PARTITION BY hws.practice_final_best_speed) as practice_final_med_best_speed,
        ROUND(MEDIAN(hws.practice_final_best_time), 3) OVER (PARTITION BY hws.practice_final_best_time) as practice_final_med_best_time,
        ROUND(MEDIAN(hws.practice_final_total_laps), 3) OVER (PARTITION BY hws.practice_final_total_laps) as practice_final_med_total_laps,
        ROUND(MEDIAN(hws.practice_final_5_lap_average_time), 3) OVER (PARTITION BY hws.practice_final_5_lap_average_time) as practice_final_med_5_lap_average_time,
        ROUND(MEDIAN(hws.practice_final_10_lap_average_time), 3) OVER (PARTITION BY hws.practice_final_10_lap_average_time) as practice_final_med_10_lap_average_time,
        ROUND(MEDIAN(hws.practice_final_20_lap_average_time), 3) OVER (PARTITION BY hws.practice_final_20_lap_average_time) as practice_final_med_20_lap_average_time,
        ROUND(MEDIAN(hws.practice_final_25_lap_average_time), 3) OVER (PARTITION BY hws.practice_final_25_lap_average_time) as practice_final_med_25_lap_average_time,
        ROUND(MEDIAN(hws.practice_final_30_lap_average_time), 3) OVER (PARTITION BY hws.practice_final_30_lap_average_time) as practice_final_med_30_lap_average_time,
        ROUND(MEDIAN(hws.practice_final_10_lap_average_speed), 3) OVER (PARTITION BY hws.practice_final_10_lap_average_speed) as practice_final_med_10_lap_average_speed,
        ROUND(MEDIAN(hws.practice_final_10_lap_start), 3) OVER (PARTITION BY hws.practice_final_10_lap_start) as practice_final_med_10_lap_start,
        ROUND(MEDIAN(hws.practice_final_10_lap_end), 3) OVER (PARTITION BY hws.practice_final_10_lap_end) as practice_final_med_10_lap_end,
        COUNT(*) as races_total
    FROM nascar.hist_weeks_stats hws
    WHERE hws.series_id = r_series_id
        AND hws.season_id = r_season_id
        AND hws.week_id = r_week_id
        AND hws.deleted_at IS NULL
        -- AND hws.car_status = 'Running' TODO: Consider making this an ENUM and filtering by only running
    GROUP BY hws.series_id, hws.season_id, hws.track_id, hws.car_driver_id
    ;
END //

DELIMITER ;
