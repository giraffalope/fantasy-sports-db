-- agg_hist_track_driver_week_results: stored procedure placeholder for NASCAR aggregation workflows.
-- Implement business logic in this procedure body.

DROP PROCEDURE IF EXISTS `agg_hist_track_driver_week_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agg_hist_track_driver_week_results`()
BEGIN
SELECT
    awr.series_id,
    awr.track_id,
    awr.driver_id,
    awr.car_generation_models_seasons_id,

    MIN(awr.r_start_position) AS r_min_start_position,
    MAX(awr.r_start_position) AS r_max_start_position,
    ROUND(AVG(awr.r_start_position), 3) AS r_avg_start_position,

    MIN(awr.r_finish_position) AS r_min_finish_position,
    MAX(awr.r_finish_position) AS r_max_finish_position,
    ROUND(AVG(awr.r_finish_position), 3) AS r_avg_finish_position,

    MIN(awr.r_place_diff) AS r_min_place_diff,
    MAX(awr.r_place_diff) AS r_max_place_diff,
    ROUND(AVG(awr.r_place_diff), 3) AS r_avg_place_diff,

    MIN(awr.r_best_position) AS r_min_best_position,
    MAX(awr.r_best_position) AS r_max_best_position,
    ROUND(AVG(awr.r_best_position), 3) AS r_avg_best_position,

    MIN(awr.r_worst_position) AS r_min_worst_position,
    MAX(awr.r_worst_position) AS r_max_worst_position,
    ROUND(AVG(awr.r_worst_position), 3) AS r_avg_worst_position,

    MIN(awr.r_average_position) AS r_min_average_position,
    MAX(awr.r_average_position) AS r_max_average_position,
    ROUND(AVG(awr.r_average_position), 3) AS r_avg_average_position,

    MIN(awr.r_green_flag_passes) AS r_min_green_flag_passes,
    MAX(awr.r_green_flag_passes) AS r_max_green_flag_passes,
    ROUND(AVG(awr.r_green_flag_passes), 3) AS r_avg_green_flag_passes,

    MIN(awr.r_green_flag_times_passed) AS r_min_green_flag_times_passed,
    MAX(awr.r_green_flag_times_passed) AS r_max_green_flag_times_passed,
    ROUND(AVG(awr.r_green_flag_times_passed), 3) AS r_avg_green_flag_times_passed,

    MIN(awr.r_green_flag_pass_diff) AS r_min_green_flag_pass_diff,
    MAX(awr.r_green_flag_pass_diff) AS r_max_green_flag_pass_diff,
    ROUND(AVG(awr.r_green_flag_pass_diff), 3) AS r_avg_green_flag_pass_diff,

    MIN(awr.r_quality_passes) AS r_min_quality_passes,
    MAX(awr.r_quality_passes) AS r_max_quality_passes,
    ROUND(AVG(awr.r_quality_passes), 3) AS r_avg_quality_passes,

    MIN(awr.r_quality_passes_pct) AS r_min_quality_passes_pct,
    MAX(awr.r_quality_passes_pct) AS r_max_quality_passes_pct,
    ROUND(AVG(awr.r_quality_passes_pct), 3) AS r_avg_quality_passes_pct,

    MIN(awr.r_total_fastest_laps) AS r_min_total_fastest_laps,
    MAX(awr.r_total_fastest_laps) AS r_max_total_fastest_laps,
    ROUND(AVG(awr.r_total_fastest_laps), 3) AS r_avg_total_fastest_laps,

    MIN(awr.r_total_fastest_laps_pct) AS r_min_total_fastest_laps_pct,
    MAX(awr.r_total_fastest_laps_pct) AS r_max_total_fastest_laps_pct,
    ROUND(AVG(awr.r_total_fastest_laps_pct), 3) AS r_avg_total_fastest_laps_pct,

    MIN(awr.r_total_top_15_laps) AS r_min_total_top_15_laps,
    MAX(awr.r_total_top_15_laps) AS r_max_total_top_15_laps,
    ROUND(AVG(awr.r_total_top_15_laps), 3) AS r_avg_total_top_15_laps,

    MIN(awr.r_total_top_15_laps_pct) AS r_min_total_top_15_laps_pct,
    MAX(awr.r_total_top_15_laps_pct) AS r_max_total_top_15_laps_pct,
    ROUND(AVG(awr.r_total_top_15_laps_pct), 3) AS r_avg_total_top_15_laps_pct,

    MIN(awr.r_total_laps_led) AS r_min_total_laps_led,
    MAX(awr.r_total_laps_led) AS r_max_total_laps_led,
    ROUND(AVG(awr.r_total_laps_led), 3) AS r_avg_total_laps_led,

    MIN(awr.r_total_laps_led_pct) AS r_min_total_laps_led_pct,
    MAX(awr.r_total_laps_led_pct) AS r_max_total_laps_led_pct,
    ROUND(AVG(awr.r_total_laps_led_pct), 3) AS r_avg_total_laps_led_pct,

    MIN(awr.r_total_laps_completed) AS r_min_total_laps_completed,
    MAX(awr.r_total_laps_completed) AS r_max_total_laps_completed,
    ROUND(AVG(awr.r_total_laps_completed), 3) AS r_avg_total_laps_completed,

    MIN(awr.r_total_laps_completed_pct) AS r_min_total_laps_completed_pct,
    MAX(awr.r_total_laps_completed_pct) AS r_max_total_laps_completed_pct,
    ROUND(AVG(awr.r_total_laps_completed_pct), 3) AS r_avg_total_laps_completed_pct,

    MIN(awr.r_driver_rating) AS r_min_driver_rating,
    MAX(awr.r_driver_rating) AS r_max_driver_rating,
    ROUND(AVG(awr.r_driver_rating), 3) AS r_avg_driver_rating,

    MIN(awr.r_avg_pitstop_crew_time) AS r_min_avg_pitstop_crew_time,
    MAX(awr.r_avg_pitstop_crew_time) AS r_max_avg_pitstop_crew_time,
    ROUND(AVG(awr.r_avg_pitstop_crew_time), 3) AS r_avg_avg_pitstop_crew_time,

    MIN(awr.r_avg_pitstop_driver_time) AS r_min_avg_pitstop_driver_time,
    MAX(awr.r_avg_pitstop_driver_time) AS r_max_avg_pitstop_driver_time,
    ROUND(AVG(awr.r_avg_pitstop_driver_time), 3) AS r_avg_avg_pitstop_driver_time,

    MIN(awr.r_total_pitstops) AS r_min_total_pitstops,
    MAX(awr.r_total_pitstops) AS r_max_total_pitstops,
    ROUND(AVG(awr.r_total_pitstops), 3) AS r_avg_total_pitstops,

    MIN(awr.r_avg_4_pitstop_crew_time) AS r_min_avg_4_pitstop_crew_time,
    MAX(awr.r_avg_4_pitstop_crew_time) AS r_max_avg_4_pitstop_crew_time,
    ROUND(AVG(awr.r_avg_4_pitstop_crew_time), 3) AS r_avg_avg_4_pitstop_crew_time,

    MIN(awr.r_avg_4_pitstop_driver_time) AS r_min_avg_4_pitstop_driver_time,
    MAX(awr.r_avg_4_pitstop_driver_time) AS r_max_avg_4_pitstop_driver_time,
    ROUND(AVG(awr.r_avg_4_pitstop_driver_time), 3) AS r_avg_avg_4_pitstop_driver_time,

    MIN(awr.r_total_4_pitstops) AS r_min_total_4_pitstops,
    MAX(awr.r_total_4_pitstops) AS r_max_total_4_pitstops,
    ROUND(AVG(awr.r_total_4_pitstops), 3) AS r_avg_total_4_pitstops,

    MIN(awr.r_avg_2l_pitstop_crew_time) AS r_min_avg_2l_pitstop_crew_time,
    MAX(awr.r_avg_2l_pitstop_crew_time) AS r_max_avg_2l_pitstop_crew_time,
    ROUND(AVG(awr.r_avg_2l_pitstop_crew_time), 3) AS r_avg_avg_2l_pitstop_crew_time,

    MIN(awr.r_avg_2l_pitstop_driver_time) AS r_min_avg_2l_pitstop_driver_time,
    MAX(awr.r_avg_2l_pitstop_driver_time) AS r_max_avg_2l_pitstop_driver_time,
    ROUND(AVG(awr.r_avg_2l_pitstop_driver_time), 3) AS r_avg_avg_2l_pitstop_driver_time,

    MIN(awr.r_total_2l_pitstops) AS r_min_total_2l_pitstops,
    MAX(awr.r_total_2l_pitstops) AS r_max_total_2l_pitstops,
    ROUND(AVG(awr.r_total_2l_pitstops), 3) AS r_avg_total_2l_pitstops,

    MIN(awr.r_avg_2r_pitstop_crew_time) AS r_min_avg_2r_pitstop_crew_time,
    MAX(awr.r_avg_2r_pitstop_crew_time) AS r_max_avg_2r_pitstop_crew_time,
    ROUND(AVG(awr.r_avg_2r_pitstop_crew_time), 3) AS r_avg_avg_2r_pitstop_crew_time,

    MIN(awr.r_avg_2r_pitstop_driver_time) AS r_min_avg_2r_pitstop_driver_time,
    MAX(awr.r_avg_2r_pitstop_driver_time) AS r_max_avg_2r_pitstop_driver_time,
    ROUND(AVG(awr.r_avg_2r_pitstop_driver_time), 3) AS r_avg_avg_2r_pitstop_driver_time,

    MIN(awr.r_total_2r_pitstops) AS r_min_total_2r_pitstops,
    MAX(awr.r_total_2r_pitstops) AS r_max_total_2r_pitstops,
    ROUND(AVG(awr.r_total_2r_pitstops), 3) AS r_avg_total_2r_pitstops,

    MIN(awr.r_total_penalties) AS r_min_total_penalties,
    MAX(awr.r_total_penalties) AS r_max_total_penalties,
    ROUND(AVG(awr.r_total_penalties), 3) AS r_avg_total_penalties,

    MIN(awr.r_total_race_laps) AS r_min_total_race_laps,
    MAX(awr.r_total_race_laps) AS r_max_total_race_laps,
    ROUND(AVG(awr.r_total_race_laps), 3) AS r_avg_total_race_laps,

    MIN(awr.r_total_race_miles) AS r_min_total_race_miles,
    MAX(awr.r_total_race_miles) AS r_max_total_race_miles,
    ROUND(AVG(awr.r_total_race_miles), 3) AS r_avg_total_race_miles,

    MIN(awr.q_finish_position) AS q_min_finish_position,
    MAX(awr.q_finish_position) AS q_max_finish_position,
    ROUND(AVG(awr.q_finish_position), 3) AS q_avg_finish_position,

    MIN(awr.q_best_speed) AS q_min_best_speed,
    MAX(awr.q_best_speed) AS q_max_best_speed,
    ROUND(AVG(awr.q_best_speed), 3) AS q_avg_best_speed,

    MIN(awr.q_best_time) AS q_min_best_time,
    MAX(awr.q_best_time) AS q_max_best_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.q_best_time))) AS q_avg_best_time,

    MIN(awr.pt_min_finish_position) AS pt_min_min_finish_position,
    MAX(awr.pt_min_finish_position) AS pt_max_min_finish_position,
    ROUND(AVG(awr.pt_min_finish_position), 3) AS pt_avg_min_finish_position,

    MIN(awr.pt_max_finish_position) AS pt_min_max_finish_position,
    MAX(awr.pt_max_finish_position) AS pt_max_max_finish_position,
    ROUND(AVG(awr.pt_max_finish_position), 3) AS pt_avg_max_finish_position,

    MIN(awr.pt_avg_finish_position) AS pt_min_avg_finish_position,
    MAX(awr.pt_avg_finish_position) AS pt_max_avg_finish_position,
    ROUND(AVG(awr.pt_avg_finish_position), 3) AS pt_avg_avg_finish_position,

    MIN(awr.pt_min_best_speed) AS pt_min_min_best_speed,
    MAX(awr.pt_min_best_speed) AS pt_max_min_best_speed,
    ROUND(AVG(awr.pt_min_best_speed), 3) AS pt_avg_min_best_speed,

    MIN(awr.pt_max_best_speed) AS pt_min_max_best_speed,
    MAX(awr.pt_max_best_speed) AS pt_max_max_best_speed,
    ROUND(AVG(awr.pt_max_best_speed), 3) AS pt_avg_max_best_speed,

    MIN(awr.pt_avg_best_speed) AS pt_min_avg_best_speed,
    MAX(awr.pt_avg_best_speed) AS pt_max_avg_best_speed,
    ROUND(AVG(awr.pt_avg_best_speed), 3) AS pt_avg_avg_best_speed,

    MIN(awr.pt_min_best_time) AS pt_min_min_best_time,
    MAX(awr.pt_min_best_time) AS pt_max_min_best_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_best_time))) AS pt_avg_min_best_time,

    MIN(awr.pt_max_best_time) AS pt_min_max_best_time,
    MAX(awr.pt_max_best_time) AS pt_max_max_best_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_best_time))) AS pt_avg_max_best_time,

    MIN(awr.pt_avg_best_time) AS pt_min_avg_best_time,
    MAX(awr.pt_avg_best_time) AS pt_max_avg_best_time,
    ROUND(AVG(awr.pt_avg_best_time), 3) AS pt_avg_avg_best_time,

    MIN(awr.pt_min_total_laps) AS pt_min_min_total_laps,
    MAX(awr.pt_min_total_laps) AS pt_max_min_total_laps,
    ROUND(AVG(awr.pt_min_total_laps), 3) AS pt_avg_min_total_laps,

    MIN(awr.pt_max_total_laps) AS pt_min_max_total_laps,
    MAX(awr.pt_max_total_laps) AS pt_max_max_total_laps,
    ROUND(AVG(awr.pt_max_total_laps), 3) AS pt_avg_max_total_laps,

    MIN(awr.pt_avg_total_laps) AS pt_min_avg_total_laps,
    MAX(awr.pt_avg_total_laps) AS pt_max_avg_total_laps,
    ROUND(AVG(awr.pt_avg_total_laps), 3) AS pt_avg_avg_total_laps,

    MIN(awr.pt_sum_total_laps) AS pt_min_sum_total_laps,
    MAX(awr.pt_sum_total_laps) AS pt_max_sum_total_laps,
    ROUND(AVG(awr.pt_sum_total_laps), 3) AS pt_avg_sum_total_laps,

    MIN(awr.pt_min_5_lap_average_time) AS pt_min_min_5_lap_average_time,
    MAX(awr.pt_min_5_lap_average_time) AS pt_max_min_5_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_5_lap_average_time))) AS pt_avg_min_5_lap_average_time,

    MIN(awr.pt_max_5_lap_average_time) AS pt_min_max_5_lap_average_time,
    MAX(awr.pt_max_5_lap_average_time) AS pt_max_max_5_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_5_lap_average_time))) AS pt_avg_max_5_lap_average_time,

    MIN(awr.pt_avg_5_lap_average_time) AS pt_min_avg_5_lap_average_time,
    MAX(awr.pt_avg_5_lap_average_time) AS pt_max_avg_5_lap_average_time,
    ROUND(AVG(awr.pt_avg_5_lap_average_time), 3) AS pt_avg_avg_5_lap_average_time,

    MIN(awr.pt_min_10_lap_average_time) AS pt_min_min_10_lap_average_time,
    MAX(awr.pt_min_10_lap_average_time) AS pt_max_min_10_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_10_lap_average_time))) AS pt_avg_min_10_lap_average_time,

    MIN(awr.pt_max_10_lap_average_time) AS pt_min_max_10_lap_average_time,
    MAX(awr.pt_max_10_lap_average_time) AS pt_max_max_10_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_10_lap_average_time))) AS pt_avg_max_10_lap_average_time,

    MIN(awr.pt_avg_10_lap_average_time) AS pt_min_avg_10_lap_average_time,
    MAX(awr.pt_avg_10_lap_average_time) AS pt_max_avg_10_lap_average_time,
    ROUND(AVG(awr.pt_avg_10_lap_average_time), 3) AS pt_avg_avg_10_lap_average_time,

    MIN(awr.pt_min_20_lap_average_time) AS pt_min_min_20_lap_average_time,
    MAX(awr.pt_min_20_lap_average_time) AS pt_max_min_20_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_20_lap_average_time))) AS pt_avg_min_20_lap_average_time,

    MIN(awr.pt_max_20_lap_average_time) AS pt_min_max_20_lap_average_time,
    MAX(awr.pt_max_20_lap_average_time) AS pt_max_max_20_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_20_lap_average_time))) AS pt_avg_max_20_lap_average_time,

    MIN(awr.pt_avg_20_lap_average_time) AS pt_min_avg_20_lap_average_time,
    MAX(awr.pt_avg_20_lap_average_time) AS pt_max_avg_20_lap_average_time,
    ROUND(AVG(awr.pt_avg_20_lap_average_time), 3) AS pt_avg_avg_20_lap_average_time,

    MIN(awr.pt_min_25_lap_average_time) AS pt_min_min_25_lap_average_time,
    MAX(awr.pt_min_25_lap_average_time) AS pt_max_min_25_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_25_lap_average_time))) AS pt_avg_min_25_lap_average_time,

    MIN(awr.pt_max_25_lap_average_time) AS pt_min_max_25_lap_average_time,
    MAX(awr.pt_max_25_lap_average_time) AS pt_max_max_25_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_25_lap_average_time))) AS pt_avg_max_25_lap_average_time,

    MIN(awr.pt_avg_25_lap_average_time) AS pt_min_avg_25_lap_average_time,
    MAX(awr.pt_avg_25_lap_average_time) AS pt_max_avg_25_lap_average_time,
    ROUND(AVG(awr.pt_avg_25_lap_average_time), 3) AS pt_avg_avg_25_lap_average_time,

    MIN(awr.pt_min_30_lap_average_time) AS pt_min_min_30_lap_average_time,
    MAX(awr.pt_min_30_lap_average_time) AS pt_max_min_30_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_min_30_lap_average_time))) AS pt_avg_min_30_lap_average_time,

    MIN(awr.pt_max_30_lap_average_time) AS pt_min_max_30_lap_average_time,
    MAX(awr.pt_max_30_lap_average_time) AS pt_max_max_30_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pt_max_30_lap_average_time))) AS pt_avg_max_30_lap_average_time,

    MIN(awr.pt_avg_30_lap_average_time) AS pt_min_avg_30_lap_average_time,
    MAX(awr.pt_avg_30_lap_average_time) AS pt_max_avg_30_lap_average_time,
    ROUND(AVG(awr.pt_avg_30_lap_average_time), 3) AS pt_avg_avg_30_lap_average_time,

    MIN(awr.pt_min_10_lap_average_speed) AS pt_min_min_10_lap_average_speed,
    MAX(awr.pt_min_10_lap_average_speed) AS pt_max_min_10_lap_average_speed,
    ROUND(AVG(awr.pt_min_10_lap_average_speed), 3) AS pt_avg_min_10_lap_average_speed,

    MIN(awr.pt_max_10_lap_average_speed) AS pt_min_max_10_lap_average_speed,
    MAX(awr.pt_max_10_lap_average_speed) AS pt_max_max_10_lap_average_speed,
    ROUND(AVG(awr.pt_max_10_lap_average_speed), 3) AS pt_avg_max_10_lap_average_speed,

    MIN(awr.pt_avg_10_lap_average_speed) AS pt_min_avg_10_lap_average_speed,
    MAX(awr.pt_avg_10_lap_average_speed) AS pt_max_avg_10_lap_average_speed,
    ROUND(AVG(awr.pt_avg_10_lap_average_speed), 3) AS pt_avg_avg_10_lap_average_speed,

    MIN(awr.pt_min_10_lap_start) AS pt_min_min_10_lap_start,
    MAX(awr.pt_min_10_lap_start) AS pt_max_min_10_lap_start,
    ROUND(AVG(awr.pt_min_10_lap_start), 3) AS pt_avg_min_10_lap_start,

    MIN(awr.pt_max_10_lap_start) AS pt_min_max_10_lap_start,
    MAX(awr.pt_max_10_lap_start) AS pt_max_max_10_lap_start,
    ROUND(AVG(awr.pt_max_10_lap_start), 3) AS pt_avg_max_10_lap_start,

    MIN(awr.pt_avg_10_lap_start) AS pt_min_avg_10_lap_start,
    MAX(awr.pt_avg_10_lap_start) AS pt_max_avg_10_lap_start,
    ROUND(AVG(awr.pt_avg_10_lap_start), 3) AS pt_avg_avg_10_lap_start,

    MIN(awr.pt_min_10_lap_end) AS pt_min_min_10_lap_end,
    MAX(awr.pt_min_10_lap_end) AS pt_max_min_10_lap_end,
    ROUND(AVG(awr.pt_min_10_lap_end), 3) AS pt_avg_min_10_lap_end,

    MIN(awr.pt_max_10_lap_end) AS pt_min_max_10_lap_end,
    MAX(awr.pt_max_10_lap_end) AS pt_max_max_10_lap_end,
    ROUND(AVG(awr.pt_max_10_lap_end), 3) AS pt_avg_max_10_lap_end,

    MIN(awr.pt_avg_10_lap_end) AS pt_min_avg_10_lap_end,
    MAX(awr.pt_avg_10_lap_end) AS pt_max_avg_10_lap_end,
    ROUND(AVG(awr.pt_avg_10_lap_end), 3) AS pt_avg_avg_10_lap_end,

    MIN(awr.pf_finish_position) AS pf_min_finish_position,
    MAX(awr.pf_finish_position) AS pf_max_finish_position,
    ROUND(AVG(awr.pf_finish_position), 3) AS pf_avg_finish_position,

    MIN(awr.pf_best_speed) AS pf_min_best_speed,
    MAX(awr.pf_best_speed) AS pf_max_best_speed,
    ROUND(AVG(awr.pf_best_speed), 3) AS pf_avg_best_speed,

    MIN(awr.pf_best_time) AS pf_min_best_time,
    MAX(awr.pf_best_time) AS pf_max_best_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_best_time))) AS pf_avg_best_time,

    MIN(awr.pf_total_laps) AS pf_min_total_laps,
    MAX(awr.pf_total_laps) AS pf_max_total_laps,
    ROUND(AVG(awr.pf_total_laps), 3) AS pf_avg_total_laps,

    MIN(awr.pf_5_lap_average_time) AS pf_min_5_lap_average_time,
    MAX(awr.pf_5_lap_average_time) AS pf_max_5_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_5_lap_average_time))) AS pf_avg_5_lap_average_time,

    MIN(awr.pf_10_lap_average_time) AS pf_min_10_lap_average_time,
    MAX(awr.pf_10_lap_average_time) AS pf_max_10_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_10_lap_average_time))) AS pf_avg_10_lap_average_time,

    MIN(awr.pf_20_lap_average_time) AS pf_min_20_lap_average_time,
    MAX(awr.pf_20_lap_average_time) AS pf_max_20_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_20_lap_average_time))) AS pf_avg_20_lap_average_time,

    MIN(awr.pf_25_lap_average_time) AS pf_min_25_lap_average_time,
    MAX(awr.pf_25_lap_average_time) AS pf_max_25_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_25_lap_average_time))) AS pf_avg_25_lap_average_time,

    MIN(awr.pf_30_lap_average_time) AS pf_min_30_lap_average_time,
    MAX(awr.pf_30_lap_average_time) AS pf_max_30_lap_average_time,
    SEC_TO_TIME(AVG(TIME_TO_SEC(awr.pf_30_lap_average_time))) AS pf_avg_30_lap_average_time,

    MIN(awr.pf_10_lap_average_speed) AS pf_min_10_lap_average_speed,
    MAX(awr.pf_10_lap_average_speed) AS pf_max_10_lap_average_speed,
    ROUND(AVG(awr.pf_10_lap_average_speed), 3) AS pf_avg_10_lap_average_speed,

    MIN(awr.pf_10_lap_start) AS pf_min_10_lap_start,
    MAX(awr.pf_10_lap_start) AS pf_max_10_lap_start,
    ROUND(AVG(awr.pf_10_lap_start), 3) AS pf_avg_10_lap_start,

    MIN(awr.pf_10_lap_end) AS pf_min_10_lap_end,
    MAX(awr.pf_10_lap_end) AS pf_max_10_lap_end,
    ROUND(AVG(awr.pf_10_lap_end), 3) AS pf_avg_10_lap_end

FROM nascar.agg_week_results awr
GROUP BY awr.series_id, awr.track_id, awr.driver_id, awr.car_generation_models_seasons_id
ORDER BY series_id, track_id, car_generation_models_seasons_id, r_avg_finish_position, r_avg_start_position;
END$$
DELIMITER ;
