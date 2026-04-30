-- agg_hist_weeks_track_type_teams_stats: stored procedure used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `agg_hist_weeks_track_type_teams_stats`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `agg_hist_weeks_track_type_teams_stats`(
    IN `r_series_id` BIGINT UNSIGNED,
    IN `r_season_id` BIGINT UNSIGNED,
    IN `r_week_id` BIGINT UNSIGNED,
    IN `r_num_prev` INT SIGNED
)
    COMMENT 'Aggregate statistics for context week r_week_id over the r_num_prev most recent prior season weeks at the same track type (excluding the context track) that have week_results. From hist_weeks_track_types; run sync_hist_weeks_track_types first. r_num_prev < 0 includes all such weeks (still ordered by week number descending).'
BEGIN
    WITH ctx AS (
        SELECT
            w0.track_id AS track_id,
            w0.number AS week_number,
            trk.track_type_id AS track_type_id
        FROM nascar.weeks w0
        JOIN nascar.tracks trk ON trk.id = w0.track_id AND trk.deleted_at IS NULL
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
            JOIN nascar.tracks trk ON trk.id = w.track_id AND trk.deleted_at IS NULL
            CROSS JOIN ctx
            WHERE w.season_id = r_season_id
                AND w.deleted_at IS NULL
                AND trk.track_type_id = ctx.track_type_id
                AND w.track_id <> ctx.track_id
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
        htt.track_type_id,
        htt.team_id,
        ROUND(AVG(htt.r_start_position), 3) as r_avg_start_position,
        ROUND(AVG(htt.r_finish_position), 3) as r_avg_finish_position,
        ROUND(AVG(htt.r_best_position), 3) as r_avg_best_position,
        ROUND(AVG(htt.r_worst_position), 3) as r_avg_worst_position,
        ROUND(AVG(htt.r_average_position), 3) as r_avg_average_position,
        ROUND(AVG(htt.r_green_flag_passes), 3) as r_avg_green_flag_passes,
        ROUND(AVG(htt.r_green_flag_times_passed), 3) as r_avg_green_flag_times_passed,
        ROUND(AVG(htt.r_green_flag_pass_diff), 3) as r_avg_green_flag_pass_diff,
        ROUND(AVG(htt.r_quality_passes), 3) as r_avg_quality_passes,
        ROUND(AVG(htt.r_quality_passes_pct), 3) as r_avg_quality_passes_pct,
        ROUND(AVG(htt.r_total_fastest_laps), 3) as r_avg_total_fastest_laps,
        ROUND(AVG(htt.r_total_fastest_laps_pct), 3) as r_avg_total_fastest_laps_pct,
        ROUND(AVG(htt.r_total_top_15_laps), 3) as r_avg_total_top_15_laps,
        ROUND(AVG(htt.r_total_top_15_laps_pct), 3) as r_avg_total_top_15_laps_pct,
        ROUND(AVG(htt.r_total_laps_led), 3) as r_avg_total_laps_led,
        ROUND(AVG(htt.r_total_laps_led_pct), 3) as r_avg_total_laps_led_pct,
        ROUND(AVG(htt.r_total_laps_completed), 3) as r_avg_total_laps_completed,
        ROUND(AVG(htt.r_total_laps_completed_pct), 3) as r_avg_total_laps_completed_pct,
        ROUND(AVG(htt.r_driver_rating), 3) as r_avg_driver_rating,
        ROUND(AVG(htt.r_avg_pitstop_crew_time), 3) as r_avg_pitstop_crew_time,
        ROUND(AVG(htt.r_avg_pitstop_driver_time), 3) as r_avg_pitstop_driver_time,
        ROUND(AVG(htt.r_total_pitstops), 3) as r_avg_total_pitstops,
        ROUND(AVG(htt.r_total_penalties), 3) as r_avg_total_penalties,
        ROUND(AVG(htt.r_total_race_laps), 3) as r_avg_total_race_laps,
        ROUND(AVG(htt.r_total_race_miles), 3) as r_avg_total_race_miles,
        ROUND(AVG(htt.q_finish_position), 3) as q_avg_finish_position,
        ROUND(AVG(htt.q_best_speed), 3) as q_avg_best_speed,
        ROUND(AVG(htt.q_best_time), 3) as q_avg_best_time,
        ROUND(AVG(htt.pt_min_finish_position), 3) as pt_avg_min_finish_position,
        ROUND(AVG(htt.pt_max_finish_position), 3) as pt_avg_max_finish_position,
        ROUND(AVG(htt.pt_avg_finish_position), 3) as pt_avg_avg_finish_position,
        ROUND(AVG(htt.pt_min_best_speed), 3) as pt_avg_min_best_speed,
        ROUND(AVG(htt.pt_max_best_speed), 3) as pt_avg_max_best_speed,
        ROUND(AVG(htt.pt_avg_best_speed), 3) as pt_avg_best_speed,
        ROUND(AVG(htt.pt_min_best_time), 3) as pt_avg_min_best_time,
        ROUND(AVG(htt.pt_max_best_time), 3) as pt_avg_max_best_time,
        ROUND(AVG(htt.pt_avg_best_time), 3) as pt_avg_best_time,
        ROUND(AVG(htt.pt_min_total_laps), 3) as pt_avg_min_total_laps,
        ROUND(AVG(htt.pt_max_total_laps), 3) as pt_avg_max_total_laps,
        ROUND(AVG(htt.pt_avg_total_laps), 3) as pt_avg_total_laps,
        ROUND(AVG(htt.pt_sum_total_laps), 3) as pt_avg_sum_total_laps,
        ROUND(AVG(htt.pt_min_5_lap_average_time), 3) as pt_avg_min_5_lap_average_time,
        ROUND(AVG(htt.pt_max_5_lap_average_time), 3) as pt_avg_max_5_lap_average_time,
        ROUND(AVG(htt.pt_avg_5_lap_average_time), 3) as pt_avg_5_lap_average_time,
        ROUND(AVG(htt.pt_min_10_lap_average_time), 3) as pt_avg_min_10_lap_average_time,
        ROUND(AVG(htt.pt_max_10_lap_average_time), 3) as pt_avg_max_10_lap_average_time,
        ROUND(AVG(htt.pt_avg_10_lap_average_time), 3) as pt_avg_10_lap_average_time,
        ROUND(AVG(htt.pt_min_20_lap_average_time), 3) as pt_avg_min_20_lap_average_time,
        ROUND(AVG(htt.pt_max_20_lap_average_time), 3) as pt_avg_max_20_lap_average_time,
        ROUND(AVG(htt.pt_avg_20_lap_average_time), 3) as pt_avg_20_lap_average_time,
        ROUND(AVG(htt.pt_min_25_lap_average_time), 3) as pt_avg_min_25_lap_average_time,
        ROUND(AVG(htt.pt_max_25_lap_average_time), 3) as pt_avg_max_25_lap_average_time,
        ROUND(AVG(htt.pt_avg_25_lap_average_time), 3) as pt_avg_25_lap_average_time,
        ROUND(AVG(htt.pt_min_30_lap_average_time), 3) as pt_avg_min_30_lap_average_time,
        ROUND(AVG(htt.pt_max_30_lap_average_time), 3) as pt_avg_max_30_lap_average_time,
        ROUND(AVG(htt.pt_avg_30_lap_average_time), 3) as pt_avg_30_lap_average_time,
        ROUND(AVG(htt.pt_min_10_lap_average_speed), 3) as pt_avg_min_10_lap_average_speed,
        ROUND(AVG(htt.pt_max_10_lap_average_speed), 3) as pt_avg_max_10_lap_average_speed,
        ROUND(AVG(htt.pt_avg_10_lap_average_speed), 3) as pt_avg_10_lap_average_speed,
        ROUND(AVG(htt.pt_min_10_lap_start), 3) as pt_avg_min_10_lap_start,
        ROUND(AVG(htt.pt_max_10_lap_start), 3) as pt_avg_max_10_lap_start,
        ROUND(AVG(htt.pt_avg_10_lap_start), 3) as pt_avg_10_lap_start,
        ROUND(AVG(htt.pt_min_10_lap_end), 3) as pt_avg_min_10_lap_end,
        ROUND(AVG(htt.pt_max_10_lap_end), 3) as pt_avg_max_10_lap_end,
        ROUND(AVG(htt.pt_avg_10_lap_end), 3) as pt_avg_10_lap_end,
        ROUND(AVG(htt.pf_finish_position), 3) as pf_avg_finish_position,
        ROUND(AVG(htt.pf_best_speed), 3) as pf_avg_best_speed,
        ROUND(AVG(htt.pf_best_time), 3) as pf_avg_best_time,
        ROUND(AVG(htt.pf_total_laps), 3) as pf_avg_total_laps,
        ROUND(AVG(htt.pf_5_lap_average_time), 3) as pf_avg_5_lap_average_time,
        ROUND(AVG(htt.pf_10_lap_average_time), 3) as pf_avg_10_lap_average_time,
        ROUND(AVG(htt.pf_20_lap_average_time), 3) as pf_avg_20_lap_average_time,
        ROUND(AVG(htt.pf_25_lap_average_time), 3) as pf_avg_25_lap_average_time,
        ROUND(AVG(htt.pf_30_lap_average_time), 3) as pf_avg_30_lap_average_time,
        ROUND(AVG(htt.pf_10_lap_average_speed), 3) as pf_avg_10_lap_average_speed,
        ROUND(AVG(htt.pf_10_lap_start), 3) as pf_avg_10_lap_start,
        ROUND(AVG(htt.pf_10_lap_end), 3) as pf_avg_10_lap_end,
        COUNT(*) as r_races_total
    FROM nascar.hist_weeks_track_types htt
    WHERE htt.series_id = r_series_id
        AND htt.season_id = r_season_id
        AND htt.deleted_at IS NULL
        AND htt.track_type_id = (SELECT track_type_id FROM ctx)
        AND htt.week_id IN (SELECT week_id FROM prev_week_ids)
        
    GROUP BY htt.track_type_id, htt.team_id
    ;
END$$
DELIMITER ;
