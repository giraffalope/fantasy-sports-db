DROP PROCEDURE IF EXISTS `load_agg_week_prev_track_cg_cars_drivers_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_prev_track_cg_cars_drivers_results`(
    IN p_series_id BIGINT UNSIGNED,
    IN p_week_id BIGINT UNSIGNED
)
    COMMENT 'Aggregate prior-track car generation-level stats for a race week into agg_week_prev_track_cg_cars_drivers_results.'
BEGIN

    delete from nascar.agg_week_prev_track_cg_cars_drivers_results
    where series_id = p_series_id
        and week_id = p_week_id
    ;

    insert into nascar.agg_week_prev_track_cg_cars_drivers_results (
        series_id,
        season_id,
        week_id,
        track_id,
        car_driver_id,
        car_generation_id,
        car_generation_total,
        avg_r_start_position,
        avg_r_finish_position,
        avg_r_place_diff,
        avg_r_best_position,
        avg_r_worst_position,
        avg_r_average_position,
        avg_r_green_flag_passes,
        avg_r_green_flag_times_passed,
        avg_r_green_flag_pass_diff,
        avg_r_quality_passes,
        avg_r_quality_passes_pct,
        avg_r_total_fastest_laps,
        avg_r_total_fastest_laps_pct,
        avg_r_total_top_15_laps,
        avg_r_total_top_15_laps_pct,
        avg_r_total_laps_led,
        avg_r_total_laps_led_pct,
        avg_r_total_laps_completed,
        avg_r_total_laps_completed_pct,
        avg_r_driver_rating,
        avg_r_avg_pitstop_crew_time,
        avg_r_avg_pitstop_driver_time,
        avg_r_total_pitstops,
        avg_r_avg_4_pitstop_crew_time,
        avg_r_avg_4_pitstop_driver_time,
        avg_r_total_4_pitstops,
        avg_r_avg_2l_pitstop_crew_time,
        avg_r_avg_2l_pitstop_driver_time,
        avg_r_total_2l_pitstops,
        avg_r_avg_2r_pitstop_crew_time,
        avg_r_avg_2r_pitstop_driver_time,
        avg_r_total_2r_pitstops,
        avg_r_total_penalties,
        avg_r_total_race_laps,
        avg_r_total_race_miles,
        avg_q_finish_position,
        avg_q_best_speed,
        avg_q_best_time,
        avg_pt_min_finish_position,
        avg_pt_max_finish_position,
        avg_pt_avg_finish_position,
        avg_pt_min_best_speed,
        avg_pt_max_best_speed,
        avg_pt_avg_best_speed,
        avg_pt_min_best_time,
        avg_pt_max_best_time,
        avg_pt_avg_best_time,
        avg_pt_min_total_laps,
        avg_pt_max_total_laps,
        avg_pt_avg_total_laps,
        avg_pt_sum_total_laps,
        avg_pt_min_5_lap_average_time,
        avg_pt_max_5_lap_average_time,
        avg_pt_avg_5_lap_average_time,
        avg_pt_min_10_lap_average_time,
        avg_pt_max_10_lap_average_time,
        avg_pt_avg_10_lap_average_time,
        avg_pt_min_20_lap_average_time,
        avg_pt_max_20_lap_average_time,
        avg_pt_avg_20_lap_average_time,
        avg_pt_min_25_lap_average_time,
        avg_pt_max_25_lap_average_time,
        avg_pt_avg_25_lap_average_time,
        avg_pt_min_30_lap_average_time,
        avg_pt_max_30_lap_average_time,
        avg_pt_avg_30_lap_average_time,
        avg_pt_min_10_lap_average_speed,
        avg_pt_max_10_lap_average_speed,
        avg_pt_avg_10_lap_average_speed,
        avg_pt_min_10_lap_start,
        avg_pt_max_10_lap_start,
        avg_pt_avg_10_lap_start,
        avg_pt_min_10_lap_end,
        avg_pt_max_10_lap_end,
        avg_pt_avg_10_lap_end,
        avg_pf_finish_position,
        avg_pf_best_speed,
        avg_pf_best_time,
        avg_pf_total_laps,
        avg_pf_5_lap_average_time,
        avg_pf_10_lap_average_time,
        avg_pf_20_lap_average_time,
        avg_pf_25_lap_average_time,
        avg_pf_30_lap_average_time,
        avg_pf_10_lap_average_speed,
        avg_pf_10_lap_start,
        avg_pf_10_lap_end
    )
    with current_week as (
        select distinct s.series_id, s.id as season_id, w.id as week_id, w.track_id
        from nascar.weeks w
        join nascar.seasons s on w.season_id = s.id and s.deleted_at is null
        join nascar.tracks t on w.track_id = t.id and t.deleted_at is null
        join nascar.races r on w.id = r.week_id and r.deleted_at is null
        where w.deleted_at IS NULL
            and s.series_id = p_series_id
            and w.id = p_week_id
    ),
    prior_weeks as (
        select distinct s.series_id, s.id as season_id, w.id as week_id, w.track_id, r.id as race_id
        from nascar.weeks w
        join nascar.seasons s on w.season_id = s.id and s.deleted_at is null
        join nascar.tracks t on w.track_id = t.id and t.deleted_at is null
        join nascar.races r on w.id = r.week_id and r.deleted_at is null
        join current_week cw on w.track_id = cw.track_id
        where w.deleted_at IS NULL
            and s.series_id = p_series_id
            and w.id < p_week_id
    ),
    current_race_results_cars_drivers as (
        select distinct cd.id as car_driver_id
        from nascar.races r
        join current_week cw on r.week_id = cw.week_id
        join nascar.race_results rr on r.id = rr.race_id and rr.deleted_at is null
        join nascar.cars_drivers cd on rr.car_driver_id = cd.id and cd.deleted_at is null
        where r.deleted_at is null
    ),
    current_race_results_car_generations as (
        select distinct crrcd.car_driver_id, awr_curr.car_generation_id
        from nascar.agg_week_results awr_curr
        join current_week cw
          on awr_curr.week_id = cw.week_id
         and awr_curr.season_id = cw.season_id
         and awr_curr.series_id = cw.series_id
        join current_race_results_cars_drivers crrcd on awr_curr.car_driver_id = crrcd.car_driver_id
        where awr_curr.deleted_at is null
    ),
    agg_week_results as (
        select awr.*
        from agg_week_results awr
        join prior_weeks pw using (series_id, season_id, week_id, track_id, race_id)
        join current_race_results_car_generations crrcg
          on awr.car_generation_id = crrcg.car_generation_id
         and awr.car_driver_id = crrcg.car_driver_id
        where awr.deleted_at IS NULL
    )
    select
        cw.series_id,
        cw.season_id,
        cw.week_id,
        cw.track_id,
        crrcg.car_driver_id,
        awr.car_generation_id,
        count(*) as car_generation_total,
        ROUND(AVG(awr.r_start_position), 3) AS avg_r_start_position,
        ROUND(AVG(awr.r_finish_position), 3) AS avg_r_finish_position,
        ROUND(AVG(awr.r_place_diff), 3) AS avg_r_place_diff,
        ROUND(AVG(awr.r_best_position), 3) AS avg_r_best_position,
        ROUND(AVG(awr.r_worst_position), 3) AS avg_r_worst_position,
        ROUND(AVG(awr.r_average_position), 3) AS avg_r_average_position,
        ROUND(AVG(awr.r_green_flag_passes), 3) AS avg_r_green_flag_passes,
        ROUND(AVG(awr.r_green_flag_times_passed), 3) AS avg_r_green_flag_times_passed,
        ROUND(AVG(awr.r_green_flag_pass_diff), 3) AS avg_r_green_flag_pass_diff,
        ROUND(AVG(awr.r_quality_passes), 3) AS avg_r_quality_passes,
        ROUND(AVG(awr.r_quality_passes_pct), 3) AS avg_r_quality_passes_pct,
        ROUND(AVG(awr.r_total_fastest_laps), 3) AS avg_r_total_fastest_laps,
        ROUND(AVG(awr.r_total_fastest_laps_pct), 3) AS avg_r_total_fastest_laps_pct,
        ROUND(AVG(awr.r_total_top_15_laps), 3) AS avg_r_total_top_15_laps,
        ROUND(AVG(awr.r_total_top_15_laps_pct), 3) AS avg_r_total_top_15_laps_pct,
        ROUND(AVG(awr.r_total_laps_led), 3) AS avg_r_total_laps_led,
        ROUND(AVG(awr.r_total_laps_led_pct), 3) AS avg_r_total_laps_led_pct,
        ROUND(AVG(awr.r_total_laps_completed), 3) AS avg_r_total_laps_completed,
        ROUND(AVG(awr.r_total_laps_completed_pct), 3) AS avg_r_total_laps_completed_pct,
        ROUND(AVG(awr.r_driver_rating), 3) AS avg_r_driver_rating,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_pitstop_crew_time)), 3)) AS avg_r_avg_pitstop_crew_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_pitstop_driver_time)), 3)) AS avg_r_avg_pitstop_driver_time,
        ROUND(AVG(awr.r_total_pitstops), 3) AS avg_r_total_pitstops,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_4_pitstop_crew_time)), 3)) AS avg_r_avg_4_pitstop_crew_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_4_pitstop_driver_time)), 3)) AS avg_r_avg_4_pitstop_driver_time,
        ROUND(AVG(awr.r_total_4_pitstops), 3) AS avg_r_total_4_pitstops,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_2l_pitstop_crew_time)), 3)) AS avg_r_avg_2l_pitstop_crew_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_2l_pitstop_driver_time)), 3)) AS avg_r_avg_2l_pitstop_driver_time,
        ROUND(AVG(awr.r_total_2l_pitstops), 3) AS avg_r_total_2l_pitstops,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_2r_pitstop_crew_time)), 3)) AS avg_r_avg_2r_pitstop_crew_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.r_avg_2r_pitstop_driver_time)), 3)) AS avg_r_avg_2r_pitstop_driver_time,
        ROUND(AVG(awr.r_total_2r_pitstops), 3) AS avg_r_total_2r_pitstops,
        ROUND(AVG(awr.r_total_penalties), 3) AS avg_r_total_penalties,
        ROUND(AVG(awr.r_total_race_laps), 3) AS avg_r_total_race_laps,
        ROUND(AVG(awr.r_total_race_miles), 3) AS avg_r_total_race_miles,
        ROUND(AVG(awr.q_finish_position), 3) AS avg_q_finish_position,
        ROUND(AVG(awr.q_best_speed), 3) AS avg_q_best_speed,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.q_best_time)), 3)) AS avg_q_best_time,
        ROUND(AVG(awr.pt_min_finish_position), 3) AS avg_pt_min_finish_position,
        ROUND(AVG(awr.pt_max_finish_position), 3) AS avg_pt_max_finish_position,
        ROUND(AVG(awr.pt_avg_finish_position), 3) AS avg_pt_avg_finish_position,
        ROUND(AVG(awr.pt_min_best_speed), 3) AS avg_pt_min_best_speed,
        ROUND(AVG(awr.pt_max_best_speed), 3) AS avg_pt_max_best_speed,
        ROUND(AVG(awr.pt_avg_best_speed), 3) AS avg_pt_avg_best_speed,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_best_time)), 3)) AS avg_pt_min_best_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_best_time)), 3)) AS avg_pt_max_best_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_best_time)), 3)) AS avg_pt_avg_best_time,
        ROUND(AVG(awr.pt_min_total_laps), 3) AS avg_pt_min_total_laps,
        ROUND(AVG(awr.pt_max_total_laps), 3) AS avg_pt_max_total_laps,
        ROUND(AVG(awr.pt_avg_total_laps), 3) AS avg_pt_avg_total_laps,
        ROUND(AVG(awr.pt_sum_total_laps), 3) AS avg_pt_sum_total_laps,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_5_lap_average_time)), 3)) AS avg_pt_min_5_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_5_lap_average_time)), 3)) AS avg_pt_max_5_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_5_lap_average_time)), 3)) AS avg_pt_avg_5_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_10_lap_average_time)), 3)) AS avg_pt_min_10_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_10_lap_average_time)), 3)) AS avg_pt_max_10_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_10_lap_average_time)), 3)) AS avg_pt_avg_10_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_20_lap_average_time)), 3)) AS avg_pt_min_20_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_20_lap_average_time)), 3)) AS avg_pt_max_20_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_20_lap_average_time)), 3)) AS avg_pt_avg_20_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_25_lap_average_time)), 3)) AS avg_pt_min_25_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_25_lap_average_time)), 3)) AS avg_pt_max_25_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_25_lap_average_time)), 3)) AS avg_pt_avg_25_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_min_30_lap_average_time)), 3)) AS avg_pt_min_30_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_max_30_lap_average_time)), 3)) AS avg_pt_max_30_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pt_avg_30_lap_average_time)), 3)) AS avg_pt_avg_30_lap_average_time,
        ROUND(AVG(awr.pt_min_10_lap_average_speed), 3) AS avg_pt_min_10_lap_average_speed,
        ROUND(AVG(awr.pt_max_10_lap_average_speed), 3) AS avg_pt_max_10_lap_average_speed,
        ROUND(AVG(awr.pt_avg_10_lap_average_speed), 3) AS avg_pt_avg_10_lap_average_speed,
        ROUND(AVG(awr.pt_min_10_lap_start), 3) AS avg_pt_min_10_lap_start,
        ROUND(AVG(awr.pt_max_10_lap_start), 3) AS avg_pt_max_10_lap_start,
        ROUND(AVG(awr.pt_avg_10_lap_start), 3) AS avg_pt_avg_10_lap_start,
        ROUND(AVG(awr.pt_min_10_lap_end), 3) AS avg_pt_min_10_lap_end,
        ROUND(AVG(awr.pt_max_10_lap_end), 3) AS avg_pt_max_10_lap_end,
        ROUND(AVG(awr.pt_avg_10_lap_end), 3) AS avg_pt_avg_10_lap_end,
        ROUND(AVG(awr.pf_finish_position), 3) AS avg_pf_finish_position,
        ROUND(AVG(awr.pf_best_speed), 3) AS avg_pf_best_speed,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_best_time)), 3)) AS avg_pf_best_time,
        ROUND(AVG(awr.pf_total_laps), 3) AS avg_pf_total_laps,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_5_lap_average_time)), 3)) AS avg_pf_5_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_10_lap_average_time)), 3)) AS avg_pf_10_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_20_lap_average_time)), 3)) AS avg_pf_20_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_25_lap_average_time)), 3)) AS avg_pf_25_lap_average_time,
        SEC_TO_TIME(ROUND(AVG(TIME_TO_SEC(awr.pf_30_lap_average_time)), 3)) AS avg_pf_30_lap_average_time,
        ROUND(AVG(awr.pf_10_lap_average_speed), 3) AS avg_pf_10_lap_average_speed,
        ROUND(AVG(awr.pf_10_lap_start), 3) AS avg_pf_10_lap_start,
        ROUND(AVG(awr.pf_10_lap_end), 3) AS avg_pf_10_lap_end
    from agg_week_results awr
    left join current_week cw on 1 = 1
    join current_race_results_car_generations crrcg
       on awr.car_generation_id = crrcg.car_generation_id
      and awr.car_driver_id = crrcg.car_driver_id
    group by cw.series_id, cw.season_id, cw.week_id, cw.track_id, crrcg.car_driver_id, awr.car_generation_id
    order by awr.series_id, awr.season_id, awr.week_id, awr.track_id, avg_r_finish_position
	;
END$$
DELIMITER ;
