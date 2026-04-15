DROP PROCEDURE IF EXISTS `nascar`.`agg_hist_weeks_track_teams_stats`;

DELIMITER //

CREATE PROCEDURE `nascar`.`agg_hist_weeks_track_teams_stats`(
    IN `r_series_id` BIGINT UNSIGNED,
    IN `r_season_id` BIGINT UNSIGNED,
    IN `r_week_id` BIGINT UNSIGNED,
    IN `r_num_prev` INT SIGNED
)
COMMENT 'Aggregate statistics for context week r_week_id over the r_num_prev most recent prior season weeks at the same track that have week_results (race stats materialized). r_num_prev < 0 includes all such weeks (still ordered by week number descending).'
BEGIN
    WITH ctx AS (
        SELECT
            w0.track_id AS track_id,
            w0.number AS week_number
        FROM nascar.weeks w0
        WHERE w0.id = r_week_id
            AND w0.season_id = r_season_id
            AND w0.deleted_at IS NULL
        LIMIT 1
    ),
    prev_week_ids AS (
        SELECT week_id
        FROM (
            SELECT
                w.id AS week_id,
                ROW_NUMBER() OVER (ORDER BY w.number DESC) AS rn
            FROM nascar.weeks w
            CROSS JOIN ctx
            WHERE w.season_id = r_season_id
                AND w.deleted_at IS NULL
                AND w.track_id = ctx.track_id
                AND w.number < ctx.week_number
                AND EXISTS (
                    SELECT 1
                    FROM nascar.week_results wr
                    WHERE wr.series_id = r_series_id
                        AND wr.season_id = r_season_id
                        AND wr.week_id = w.id
                        AND wr.deleted_at IS NULL
                )
        ) ranked
        WHERE r_num_prev < 0 OR rn <= r_num_prev
    )
    SELECT
        r_series_id AS series_id,
        r_season_id AS season_id,
        r_week_id AS week_id,
        hws.track_id,
        hws.team_id,
        ROUND(AVG(hws.r_start_position), 3) as r_avg_start_position,
        ROUND(AVG(hws.r_finish_position), 3) as r_avg_finish_position,
        ROUND(AVG(hws.r_best_position), 3) as r_avg_best_position,
        ROUND(AVG(hws.r_worst_position), 3) as r_avg_worst_position,
        ROUND(AVG(hws.r_average_position), 3) as r_avg_average_position,
        ROUND(AVG(hws.r_green_flag_passes), 3) as r_avg_green_flag_passes,
        ROUND(AVG(hws.r_green_flag_times_passed), 3) as r_avg_green_flag_times_passed,
        ROUND(AVG(hws.r_green_flag_pass_diff), 3) as r_avg_green_flag_pass_diff,
        ROUND(AVG(hws.r_quality_passes), 3) as r_avg_quality_passes,
        ROUND(AVG(hws.r_quality_passes_pct), 3) as r_avg_quality_passes_pct,
        ROUND(AVG(hws.r_total_fastest_laps), 3) as r_avg_total_fastest_laps,
        ROUND(AVG(hws.r_total_fastest_laps_pct), 3) as r_avg_total_fastest_laps_pct,
        ROUND(AVG(hws.r_total_top_15_laps), 3) as r_avg_total_top_15_laps,
        ROUND(AVG(hws.r_total_top_15_laps_pct), 3) as r_avg_total_top_15_laps_pct,
        ROUND(AVG(hws.r_total_laps_led), 3) as r_avg_total_laps_led,
        ROUND(AVG(hws.r_total_laps_led_pct), 3) as r_avg_total_laps_led_pct,
        ROUND(AVG(hws.r_total_laps_completed), 3) as r_avg_total_laps_completed,
        ROUND(AVG(hws.r_total_laps_completed_pct), 3) as r_avg_total_laps_completed_pct,
        ROUND(AVG(hws.r_driver_rating), 3) as r_avg_driver_rating,
        ROUND(AVG(hws.r_avg_pitstop_crew_time), 3) as r_avg_pitstop_crew_time,
        ROUND(AVG(hws.r_avg_pitstop_driver_time), 3) as r_avg_pitstop_driver_time,
        ROUND(AVG(hws.r_total_pitstops), 3) as r_avg_total_pitstops,
        ROUND(AVG(hws.r_total_penalties), 3) as r_avg_total_penalties,
        ROUND(AVG(hws.r_total_race_laps), 3) as r_avg_total_race_laps,
        ROUND(AVG(hws.r_total_race_miles), 3) as r_avg_total_race_miles,
        ROUND(AVG(hws.q_finish_position), 3) as q_avg_finish_position,
        ROUND(AVG(hws.q_best_speed), 3) as q_avg_best_speed,
        ROUND(AVG(hws.q_best_time), 3) as q_avg_best_time,
        ROUND(AVG(hws.pt_min_finish_position), 3) as pt_avg_min_finish_position,
        ROUND(AVG(hws.pt_max_finish_position), 3) as pt_avg_max_finish_position,
        ROUND(AVG(hws.pt_avg_finish_position), 3) as pt_avg_avg_finish_position,
        ROUND(AVG(hws.pt_min_best_speed), 3) as pt_avg_min_best_speed,
        ROUND(AVG(hws.pt_max_best_speed), 3) as pt_avg_max_best_speed,
        ROUND(AVG(hws.pt_avg_best_speed), 3) as pt_avg_best_speed,
        ROUND(AVG(hws.pt_min_best_time), 3) as pt_avg_min_best_time,
        ROUND(AVG(hws.pt_max_best_time), 3) as pt_avg_max_best_time,
        ROUND(AVG(hws.pt_avg_best_time), 3) as pt_avg_best_time,
        ROUND(AVG(hws.pt_min_total_laps), 3) as pt_avg_min_total_laps,
        ROUND(AVG(hws.pt_max_total_laps), 3) as pt_avg_max_total_laps,
        ROUND(AVG(hws.pt_avg_total_laps), 3) as pt_avg_total_laps,
        ROUND(AVG(hws.pt_sum_total_laps), 3) as pt_avg_sum_total_laps,
        ROUND(AVG(hws.pt_min_5_lap_average_time), 3) as pt_avg_min_5_lap_average_time,
        ROUND(AVG(hws.pt_max_5_lap_average_time), 3) as pt_avg_max_5_lap_average_time,
        ROUND(AVG(hws.pt_avg_5_lap_average_time), 3) as pt_avg_5_lap_average_time,
        ROUND(AVG(hws.pt_min_10_lap_average_time), 3) as pt_avg_min_10_lap_average_time,
        ROUND(AVG(hws.pt_max_10_lap_average_time), 3) as pt_avg_max_10_lap_average_time,
        ROUND(AVG(hws.pt_avg_10_lap_average_time), 3) as pt_avg_10_lap_average_time,
        ROUND(AVG(hws.pt_min_20_lap_average_time), 3) as pt_avg_min_20_lap_average_time,
        ROUND(AVG(hws.pt_max_20_lap_average_time), 3) as pt_avg_max_20_lap_average_time,
        ROUND(AVG(hws.pt_avg_20_lap_average_time), 3) as pt_avg_20_lap_average_time,
        ROUND(AVG(hws.pt_min_25_lap_average_time), 3) as pt_avg_min_25_lap_average_time,
        ROUND(AVG(hws.pt_max_25_lap_average_time), 3) as pt_avg_max_25_lap_average_time,
        ROUND(AVG(hws.pt_avg_25_lap_average_time), 3) as pt_avg_25_lap_average_time,
        ROUND(AVG(hws.pt_min_30_lap_average_time), 3) as pt_avg_min_30_lap_average_time,
        ROUND(AVG(hws.pt_max_30_lap_average_time), 3) as pt_avg_max_30_lap_average_time,
        ROUND(AVG(hws.pt_avg_30_lap_average_time), 3) as pt_avg_30_lap_average_time,
        ROUND(AVG(hws.pt_min_10_lap_average_speed), 3) as pt_avg_min_10_lap_average_speed,
        ROUND(AVG(hws.pt_max_10_lap_average_speed), 3) as pt_avg_max_10_lap_average_speed,
        ROUND(AVG(hws.pt_avg_10_lap_average_speed), 3) as pt_avg_10_lap_average_speed,
        ROUND(AVG(hws.pt_min_10_lap_start), 3) as pt_avg_min_10_lap_start,
        ROUND(AVG(hws.pt_max_10_lap_start), 3) as pt_avg_max_10_lap_start,
        ROUND(AVG(hws.pt_avg_10_lap_start), 3) as pt_avg_10_lap_start,
        ROUND(AVG(hws.pt_min_10_lap_end), 3) as pt_avg_min_10_lap_end,
        ROUND(AVG(hws.pt_max_10_lap_end), 3) as pt_avg_max_10_lap_end,
        ROUND(AVG(hws.pt_avg_10_lap_end), 3) as pt_avg_10_lap_end,
        ROUND(AVG(hws.pf_finish_position), 3) as pf_avg_finish_position,
        ROUND(AVG(hws.pf_best_speed), 3) as pf_avg_best_speed,
        ROUND(AVG(hws.pf_best_time), 3) as pf_avg_best_time,
        ROUND(AVG(hws.pf_total_laps), 3) as pf_avg_total_laps,
        ROUND(AVG(hws.pf_5_lap_average_time), 3) as pf_avg_5_lap_average_time,
        ROUND(AVG(hws.pf_10_lap_average_time), 3) as pf_avg_10_lap_average_time,
        ROUND(AVG(hws.pf_20_lap_average_time), 3) as pf_avg_20_lap_average_time,
        ROUND(AVG(hws.pf_25_lap_average_time), 3) as pf_avg_25_lap_average_time,
        ROUND(AVG(hws.pf_30_lap_average_time), 3) as pf_avg_30_lap_average_time,
        ROUND(AVG(hws.pf_10_lap_average_speed), 3) as pf_avg_10_lap_average_speed,
        ROUND(AVG(hws.pf_10_lap_start), 3) as pf_avg_10_lap_start,
        ROUND(AVG(hws.pf_10_lap_end), 3) as pf_avg_10_lap_end,
        COUNT(*) as r_races_total
    FROM nascar.week_results hws
    WHERE hws.series_id = r_series_id
        AND hws.season_id = r_season_id
        AND hws.deleted_at IS NULL
        AND hws.track_id = (SELECT track_id FROM ctx)
        AND hws.week_id IN (SELECT week_id FROM prev_week_ids)
        -- AND hws.car_status = 'Running' TODO: Consider making this an ENUM and filtering by only running
    GROUP BY hws.series_id, hws.season_id, hws.track_id, hws.team_id
    ;
END //

DELIMITER ;
