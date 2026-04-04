DELIMITER //

CREATE PROCEDURE `nascar`.`agg_hist_weeks_track_manufacturers_avg_stats`(
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
        hws.manufacturer_id,
        ROUND(AVG(hws.race_start_position), 3) as race_avg_start_position,
        ROUND(AVG(hws.race_finish_position), 3) as race_avg_finish_position,
        ROUND(AVG(hws.race_best_position), 3) as race_avg_best_position,
        ROUND(AVG(hws.race_worst_position), 3) as race_avg_worst_position,
        ROUND(AVG(hws.race_average_position), 3) as race_avg_average_position,
        ROUND(AVG(hws.race_green_flag_passes), 3) as race_avg_green_flag_passes,
        ROUND(AVG(hws.race_green_flag_times_passed), 3) as race_avg_green_flag_times_passed,
        ROUND(AVG(hws.race_green_flag_pass_diff), 3) as race_avg_green_flag_pass_diff,
        ROUND(AVG(hws.race_quality_passes), 3) as race_avg_quality_passes,
        ROUND(AVG(hws.race_quality_passes_pct), 3) as race_avg_quality_passes_pct,
        ROUND(AVG(hws.race_total_fastest_laps), 3) as race_avg_total_fastest_laps,
        ROUND(AVG(hws.race_total_fastest_laps_pct), 3) as race_avg_total_fastest_laps_pct,
        ROUND(AVG(hws.race_total_top_15_laps), 3) as race_avg_total_top_15_laps,
        ROUND(AVG(hws.race_total_top_15_laps_pct), 3) as race_avg_total_top_15_laps_pct,
        ROUND(AVG(hws.race_total_laps_led), 3) as race_avg_total_laps_led,
        ROUND(AVG(hws.race_total_laps_led_pct), 3) as race_avg_total_laps_led_pct,
        ROUND(AVG(hws.race_total_laps_completed), 3) as race_avg_total_laps_completed,
        ROUND(AVG(hws.race_total_laps_completed_pct), 3) as race_avg_total_laps_completed_pct,
        ROUND(AVG(hws.race_driver_rating), 3) as race_avg_driver_rating,
        ROUND(AVG(hws.race_avg_pitstop_crew_time), 3) as race_avg_pitstop_crew_time,
        ROUND(AVG(hws.race_avg_pitstop_driver_time), 3) as race_avg_pitstop_driver_time,
        ROUND(AVG(hws.race_total_pitstops), 3) as race_avg_total_pitstops,
        ROUND(AVG(hws.race_total_penalties), 3) as race_avg_total_penalties,
        ROUND(AVG(hws.race_total_race_laps), 3) as race_avg_total_race_laps,
        ROUND(AVG(hws.race_total_race_miles), 3) as race_avg_total_race_miles,
        ROUND(AVG(hws.qualifying_finish_position), 3) as qualifying_avg_finish_position,
        ROUND(AVG(hws.qualifying_best_speed), 3) as qualifying_avg_best_speed,
        ROUND(AVG(hws.qualifying_best_time), 3) as qualifying_avg_best_time,
        ROUND(AVG(hws.practice_total_min_finish_position), 3) as practice_total_avg_min_finish_position,
        ROUND(AVG(hws.practice_total_max_finish_position), 3) as practice_total_avg_max_finish_position,
        ROUND(AVG(hws.practice_total_avg_finish_position), 3) as practice_total_avg_avg_finish_position,
        ROUND(AVG(hws.practice_total_min_best_speed), 3) as practice_total_avg_min_best_speed,
        ROUND(AVG(hws.practice_total_max_best_speed), 3) as practice_total_avg_max_best_speed,
        ROUND(AVG(hws.practice_total_avg_best_speed), 3) as practice_total_avg_best_speed,
        ROUND(AVG(hws.practice_total_min_best_time), 3) as practice_total_avg_min_best_time,
        ROUND(AVG(hws.practice_total_max_best_time), 3) as practice_total_avg_max_best_time,
        ROUND(AVG(hws.practice_total_avg_best_time), 3) as practice_total_avg_best_time,
        ROUND(AVG(hws.practice_total_min_total_laps), 3) as practice_total_avg_min_total_laps,
        ROUND(AVG(hws.practice_total_max_total_laps), 3) as practice_total_avg_max_total_laps,
        ROUND(AVG(hws.practice_total_avg_total_laps), 3) as practice_total_avg_total_laps,
        ROUND(AVG(hws.practice_total_sum_total_laps), 3) as practice_total_avg_sum_total_laps,
        ROUND(AVG(hws.practice_total_min_5_lap_average_time), 3) as practice_total_avg_min_5_lap_average_time,
        ROUND(AVG(hws.practice_total_max_5_lap_average_time), 3) as practice_total_avg_max_5_lap_average_time,
        ROUND(AVG(hws.practice_total_avg_5_lap_average_time), 3) as practice_total_avg_5_lap_average_time,
        ROUND(AVG(hws.practice_total_min_10_lap_average_time), 3) as practice_total_avg_min_10_lap_average_time,
        ROUND(AVG(hws.practice_total_max_10_lap_average_time), 3) as practice_total_avg_max_10_lap_average_time,
        ROUND(AVG(hws.practice_total_avg_10_lap_average_time), 3) as practice_total_avg_10_lap_average_time,
        ROUND(AVG(hws.practice_total_min_20_lap_average_time), 3) as practice_total_avg_min_20_lap_average_time,
        ROUND(AVG(hws.practice_total_max_20_lap_average_time), 3) as practice_total_avg_max_20_lap_average_time,
        ROUND(AVG(hws.practice_total_avg_20_lap_average_time), 3) as practice_total_avg_20_lap_average_time,
        ROUND(AVG(hws.practice_total_min_25_lap_average_time), 3) as practice_total_avg_min_25_lap_average_time,
        ROUND(AVG(hws.practice_total_max_25_lap_average_time), 3) as practice_total_avg_max_25_lap_average_time,
        ROUND(AVG(hws.practice_total_avg_25_lap_average_time), 3) as practice_total_avg_25_lap_average_time,
        ROUND(AVG(hws.practice_total_min_30_lap_average_time), 3) as practice_total_avg_min_30_lap_average_time,
        ROUND(AVG(hws.practice_total_max_30_lap_average_time), 3) as practice_total_avg_max_30_lap_average_time,
        ROUND(AVG(hws.practice_total_avg_30_lap_average_time), 3) as practice_total_avg_30_lap_average_time,
        ROUND(AVG(hws.practice_total_min_10_lap_average_speed), 3) as practice_total_avg_min_10_lap_average_speed,
        ROUND(AVG(hws.practice_total_max_10_lap_average_speed), 3) as practice_total_avg_max_10_lap_average_speed,
        ROUND(AVG(hws.practice_total_avg_10_lap_average_speed), 3) as practice_total_avg_10_lap_average_speed,
        ROUND(AVG(hws.practice_total_min_10_lap_start), 3) as practice_total_avg_min_10_lap_start,
        ROUND(AVG(hws.practice_total_max_10_lap_start), 3) as practice_total_avg_max_10_lap_start,
        ROUND(AVG(hws.practice_total_avg_10_lap_start), 3) as practice_total_avg_10_lap_start,
        ROUND(AVG(hws.practice_total_min_10_lap_end), 3) as practice_total_avg_min_10_lap_end,
        ROUND(AVG(hws.practice_total_max_10_lap_end), 3) as practice_total_avg_max_10_lap_end,
        ROUND(AVG(hws.practice_total_avg_10_lap_end), 3) as practice_total_avg_10_lap_end,
        ROUND(AVG(hws.practice_final_finish_position), 3) as practice_final_avg_finish_position,
        ROUND(AVG(hws.practice_final_best_speed), 3) as practice_final_avg_best_speed,
        ROUND(AVG(hws.practice_final_best_time), 3) as practice_final_avg_best_time,
        ROUND(AVG(hws.practice_final_total_laps), 3) as practice_final_avg_total_laps,
        ROUND(AVG(hws.practice_final_5_lap_average_time), 3) as practice_final_avg_5_lap_average_time,
        ROUND(AVG(hws.practice_final_10_lap_average_time), 3) as practice_final_avg_10_lap_average_time,
        ROUND(AVG(hws.practice_final_20_lap_average_time), 3) as practice_final_avg_20_lap_average_time,
        ROUND(AVG(hws.practice_final_25_lap_average_time), 3) as practice_final_avg_25_lap_average_time,
        ROUND(AVG(hws.practice_final_30_lap_average_time), 3) as practice_final_avg_30_lap_average_time,
        ROUND(AVG(hws.practice_final_10_lap_average_speed), 3) as practice_final_avg_10_lap_average_speed,
        ROUND(AVG(hws.practice_final_10_lap_start), 3) as practice_final_avg_10_lap_start,
        ROUND(AVG(hws.practice_final_10_lap_end), 3) as practice_final_avg_10_lap_end,
        COUNT(*) as races_total
    FROM nascar.hist_weeks_stats hws
    WHERE hws.series_id = r_series_id
        AND hws.season_id = r_season_id
        AND hws.week_id = r_week_id
        AND hws.deleted_at IS NULL
        -- AND hws.car_status = 'Running' TODO: Consider making this an ENUM and filtering by only running
    GROUP BY hws.series_id, hws.season_id, hws.track_id, hws.manufacturer_id
    ;
END //

DELIMITER ;
