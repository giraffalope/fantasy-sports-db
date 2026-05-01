-- load_agg_week_results: stored procedure used by NASCAR hourly aggregate backfill pipeline.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `load_agg_week_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_results`()
    COMMENT 'Load weekly aggregate race features for weeks that have race results but no active agg_week_results rows, or with active rows having NULL finish position.'
BEGIN
    DELETE awr
    FROM `nascar`.`agg_week_results` awr
    WHERE awr.`deleted_at` IS NULL
      AND awr.`week_id` IN (
          SELECT DISTINCT w.id
          FROM nascar.race_results rr
          JOIN nascar.races r ON rr.race_id = r.id AND r.deleted_at IS NULL
          JOIN nascar.weeks w ON r.week_id = w.id AND w.deleted_at IS NULL
          JOIN nascar.seasons s ON w.season_id = s.id AND s.deleted_at IS NULL
          JOIN nascar.series sr ON s.series_id = sr.id AND sr.deleted_at IS NULL
          WHERE rr.deleted_at IS NULL
              AND (
                  NOT EXISTS (
                      SELECT 1
                      FROM nascar.agg_week_results awr_missing
                      WHERE awr_missing.week_id = w.id
                          AND awr_missing.deleted_at IS NULL
                  )
                  OR EXISTS (
                      SELECT 1
                      FROM nascar.agg_week_results awr_bad
                      WHERE awr_bad.week_id = w.id
                          AND awr_bad.deleted_at IS NULL
                          AND awr_bad.r_finish_position IS NULL
                          AND awr_bad.race_id = rr.race_id
                          AND awr_bad.car_driver_id = rr.car_driver_id
                          AND rr.finish_position IS NOT NULL
                  )
              )
      );

    INSERT IGNORE INTO `nascar`.`agg_week_results` (
        `series_id`,
        `season_id`,
        `week_id`,
        `track_id`,
        `race_id`,
        `car_driver_id`,
        `car_id`,
        `manufacturer_id`,
        `team_id`,
        `driver_id`,
        `r_start_position`,
        `r_finish_position`,
        `r_place_diff`,
        `r_best_position`,
        `r_worst_position`,
        `r_average_position`,
        `r_green_flag_passes`,
        `r_green_flag_times_passed`,
        `r_green_flag_pass_diff`,
        `r_quality_passes`,
        `r_quality_passes_pct`,
        `r_total_fastest_laps`,
        `r_total_fastest_laps_pct`,
        `r_total_top_15_laps`,
        `r_total_top_15_laps_pct`,
        `r_total_laps_led`,
        `r_total_laps_led_pct`,
        `r_total_laps_completed`,
        `r_total_laps_completed_pct`,
        `r_driver_rating`,
        `r_car_status`,
        `r_avg_pitstop_crew_time`,
        `r_avg_pitstop_driver_time`,
        `r_total_pitstops`,
        `r_avg_4_pitstop_crew_time`,
        `r_avg_4_pitstop_driver_time`,
        `r_total_4_pitstops`,
        `r_avg_2l_pitstop_crew_time`,
        `r_avg_2l_pitstop_driver_time`,
        `r_total_2l_pitstops`,
        `r_avg_2r_pitstop_crew_time`,
        `r_avg_2r_pitstop_driver_time`,
        `r_total_2r_pitstops`,
        `r_total_penalties`,
        `r_total_race_laps`,
        `r_total_race_miles`,
        `q_finish_position`,
        `q_best_speed`,
        `q_best_time`,
        `pt_min_finish_position`,
        `pt_max_finish_position`,
        `pt_avg_finish_position`,
        `pt_min_best_speed`,
        `pt_max_best_speed`,
        `pt_avg_best_speed`,
        `pt_min_best_time`,
        `pt_max_best_time`,
        `pt_avg_best_time`,
        `pt_min_total_laps`,
        `pt_max_total_laps`,
        `pt_avg_total_laps`,
        `pt_sum_total_laps`,
        `pt_min_5_lap_average_time`,
        `pt_max_5_lap_average_time`,
        `pt_avg_5_lap_average_time`,
        `pt_min_10_lap_average_time`,
        `pt_max_10_lap_average_time`,
        `pt_avg_10_lap_average_time`,
        `pt_min_20_lap_average_time`,
        `pt_max_20_lap_average_time`,
        `pt_avg_20_lap_average_time`,
        `pt_min_25_lap_average_time`,
        `pt_max_25_lap_average_time`,
        `pt_avg_25_lap_average_time`,
        `pt_min_30_lap_average_time`,
        `pt_max_30_lap_average_time`,
        `pt_avg_30_lap_average_time`,
        `pt_min_10_lap_average_speed`,
        `pt_max_10_lap_average_speed`,
        `pt_avg_10_lap_average_speed`,
        `pt_min_10_lap_start`,
        `pt_max_10_lap_start`,
        `pt_avg_10_lap_start`,
        `pt_min_10_lap_end`,
        `pt_max_10_lap_end`,
        `pt_avg_10_lap_end`,
        `pf_finish_position`,
        `pf_best_speed`,
        `pf_best_time`,
        `pf_total_laps`,
        `pf_5_lap_average_time`,
        `pf_10_lap_average_time`,
        `pf_20_lap_average_time`,
        `pf_25_lap_average_time`,
        `pf_30_lap_average_time`,
        `pf_10_lap_average_speed`,
        `pf_10_lap_start`,
        `pf_10_lap_end`
    )
    WITH
    weeks AS (
        SELECT DISTINCT
            sr.id AS series_id,
            s.id AS season_id,
            w.id AS week_id,
            w.track_id AS track_id
        FROM nascar.race_results rr
        JOIN nascar.races r ON rr.race_id = r.id AND r.deleted_at IS NULL
        JOIN nascar.weeks w ON r.week_id = w.id AND w.deleted_at IS NULL
        JOIN nascar.seasons s ON w.season_id = s.id AND s.deleted_at IS NULL
        JOIN nascar.series sr ON s.series_id = sr.id AND sr.deleted_at IS NULL
        WHERE rr.deleted_at IS NULL
            AND (
                NOT EXISTS (
                    SELECT 1
                    FROM nascar.agg_week_results awr_missing
                    WHERE awr_missing.week_id = w.id
                        AND awr_missing.deleted_at IS NULL
                )
                OR EXISTS (
                    SELECT 1
                    FROM nascar.agg_week_results awr_bad
                    WHERE awr_bad.week_id = w.id
                        AND awr_bad.deleted_at IS NULL
                        AND awr_bad.r_finish_position IS NULL
                        AND awr_bad.race_id = rr.race_id
                        AND awr_bad.car_driver_id = rr.car_driver_id
                        AND rr.finish_position IS NOT NULL
                )
            )
    ),
    tracks AS (
        SELECT DISTINCT
            w.series_id,
            w.season_id,
            w.week_id,
            t.id AS track_id
        FROM nascar.tracks t
        JOIN weeks w ON t.id = w.track_id
        WHERE t.deleted_at IS NULL
    ),
    weeks_practices AS (
        SELECT DISTINCT
            t.series_id,
            t.season_id,
            t.week_id,
            t.track_id,
            p.id AS practice_id,
            p.number AS practice_number
        FROM nascar.practices p
        JOIN tracks t USING (week_id)
        WHERE p.deleted_at IS NULL
    ),
    weeks_qualifyings AS (
        SELECT DISTINCT
            t.series_id,
            t.season_id,
            t.week_id,
            t.track_id,
            q.id AS qualifying_id
        FROM nascar.qualifyings q
        JOIN tracks t USING (week_id)
        WHERE q.deleted_at IS NULL
    ),
    weeks_races AS (
        SELECT DISTINCT
            t.series_id,
            t.season_id,
            t.week_id,
            t.track_id,
            r.id AS race_id
        FROM nascar.races r
        JOIN tracks t USING (week_id)
        WHERE r.deleted_at IS NULL
    ),
    weeks_races_penalties AS (
        SELECT
            r.series_id,
            r.season_id,
            r.week_id,
            r.track_id,
            r.race_id,
            pn.car_driver_id,
            count(*) AS total_penalties
        FROM nascar.penalties pn
        JOIN weeks_races r USING (race_id)
        WHERE pn.deleted_at IS NULL
        GROUP BY r.series_id, r.season_id, r.week_id, r.track_id, r.race_id, pn.car_driver_id
    ),
    weeks_races_pitstops AS (
        SELECT
            p.car_driver_id AS car_driver_id,
            p.crew_time,
            p.driver_time,
            p.type
        FROM nascar.pitstops p
        JOIN weeks_races r USING (race_id)
        WHERE p.deleted_at IS NULL
    ),
    weeks_races_pitstops_totals AS (
        SELECT
            wrp.car_driver_id,
            ROUND(AVG(wrp.crew_time), 3) AS avg_pitstop_crew_time,
            ROUND(AVG(wrp.driver_time), 3) AS avg_pitstop_driver_time,
            COUNT(*) AS total_pitstops
        FROM weeks_races_pitstops wrp
        GROUP BY wrp.car_driver_id
    ),
    weeks_races_pitstops_4_totals AS (
        SELECT
            wrp.car_driver_id,
            ROUND(AVG(wrp.crew_time), 3) AS avg_4_pitstop_crew_time,
            ROUND(AVG(wrp.driver_time), 3) AS avg_4_pitstop_driver_time,
            COUNT(*) AS total_4_pitstops
        FROM weeks_races_pitstops wrp
        WHERE wrp.type = 'FOUR_WHEEL_CHANGE'
        GROUP BY wrp.car_driver_id
    ),
    weeks_races_pitstops_2l_totals AS (
        SELECT
            wrp.car_driver_id,
            ROUND(AVG(wrp.crew_time), 3) AS avg_2l_pitstop_crew_time,
            ROUND(AVG(wrp.driver_time), 3) AS avg_2l_pitstop_driver_time,
            COUNT(*) AS total_2l_pitstops
        FROM weeks_races_pitstops wrp
        WHERE wrp.type = 'TWO_WHEEL_CHANGE_LEFT'
        GROUP BY wrp.car_driver_id
    ),
    weeks_races_pitstops_2r_totals AS (
        SELECT
            wrp.car_driver_id,
            ROUND(AVG(wrp.crew_time), 3) AS avg_2r_pitstop_crew_time,
            ROUND(AVG(wrp.driver_time), 3) AS avg_2r_pitstop_driver_time,
            COUNT(*) AS total_2r_pitstops
        FROM weeks_races_pitstops wrp
        WHERE wrp.type = 'TWO_WHEEL_CHANGE_RIGHT'
        GROUP BY wrp.car_driver_id
    ),
    weeks_practices_results AS (
        SELECT DISTINCT
            wp.series_id,
            wp.season_id,
            wp.week_id,
            wp.track_id,
            wp.practice_id,
            wp.practice_number,
            pr.car_driver_id AS car_driver_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            pr.finish_position,
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
        JOIN weeks_practices wp USING (practice_id)
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
    weeks_practices_results_final AS (
        SELECT wpr.*
        FROM weeks_practices_results wpr
        JOIN (
            SELECT
                series_id,
                season_id,
                week_id,
                track_id,
                MAX(practice_number) AS practice_number
            FROM weeks_practices_results
            GROUP BY series_id, season_id, week_id, track_id
        ) fp
            ON fp.series_id = wpr.series_id
            AND fp.season_id = wpr.season_id
            AND fp.week_id = wpr.week_id
            AND fp.track_id = wpr.track_id
            AND fp.practice_number = wpr.practice_number
    ),
    weeks_practices_results_total AS (
        SELECT
            series_id,
            season_id,
            week_id,
            track_id,
            practice_id,
            practice_number,
            car_driver_id,
            car_id,
            manufacturer_id,
            team_id,
            driver_id,
            MIN(finish_position) AS min_finish_position,
            MAX(finish_position) AS max_finish_position,
            ROUND(AVG(finish_position), 3) AS avg_finish_position,
            MIN(best_speed) AS min_best_speed,
            MAX(best_speed) AS max_best_speed,
            ROUND(AVG(best_speed), 3) AS avg_best_speed,
            MIN(best_time) AS min_best_time,
            MAX(best_time) AS max_best_time,
            ROUND(AVG(best_time), 3) AS avg_best_time,
            MIN(total_laps) AS min_total_laps,
            MAX(total_laps) AS max_total_laps,
            ROUND(AVG(total_laps), 3) AS avg_total_laps,
            SUM(total_laps) AS sum_total_laps,
            MIN(5_lap_average_time) AS min_5_lap_average_time,
            MAX(5_lap_average_time) AS max_5_lap_average_time,
            ROUND(AVG(5_lap_average_time), 3) AS avg_5_lap_average_time,
            MIN(10_lap_average_time) AS min_10_lap_average_time,
            MAX(10_lap_average_time) AS max_10_lap_average_time,
            ROUND(AVG(10_lap_average_time), 3) AS avg_10_lap_average_time,
            MIN(20_lap_average_time) AS min_20_lap_average_time,
            MAX(20_lap_average_time) AS max_20_lap_average_time,
            ROUND(AVG(20_lap_average_time), 3) AS avg_20_lap_average_time,
            MIN(25_lap_average_time) AS min_25_lap_average_time,
            MAX(25_lap_average_time) AS max_25_lap_average_time,
            ROUND(AVG(25_lap_average_time), 3) AS avg_25_lap_average_time,
            MIN(30_lap_average_time) AS min_30_lap_average_time,
            MAX(30_lap_average_time) AS max_30_lap_average_time,
            ROUND(AVG(30_lap_average_time), 3) AS avg_30_lap_average_time,
            MIN(10_lap_average_speed) AS min_10_lap_average_speed,
            MAX(10_lap_average_speed) AS max_10_lap_average_speed,
            ROUND(AVG(10_lap_average_speed), 3) AS avg_10_lap_average_speed,
            MIN(10_lap_start) AS min_10_lap_start,
            MAX(10_lap_start) AS max_10_lap_start,
            ROUND(AVG(10_lap_start), 3) AS avg_10_lap_start,
            MIN(10_lap_end) AS min_10_lap_end,
            MAX(10_lap_end) AS max_10_lap_end,
            ROUND(AVG(10_lap_end), 3) AS avg_10_lap_end
        FROM weeks_practices_results
        GROUP BY series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id
    ),
    weeks_qualifying_results AS (
        SELECT DISTINCT
            wq.series_id,
            wq.season_id,
            wq.week_id,
            wq.track_id,
            wq.qualifying_id,
            qr.car_driver_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            qr.finish_position,
            qr.best_speed,
            qr.best_time
        FROM nascar.qualifying_results qr
        JOIN weeks_qualifyings wq USING (qualifying_id)
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
    weeks_race_results_max AS (
        SELECT
            rr.race_id,
            MAX(total_laps_completed) AS total_laps_completed
        FROM nascar.race_results rr
        JOIN weeks_races wr USING (race_id)
        GROUP BY rr.race_id
    ),
    weeks_race_results AS (
        SELECT
            wr.series_id,
            wr.season_id,
            wr.week_id,
            wr.track_id,
            wr.race_id,
            rr.car_driver_id,
            c.id AS car_id,
            m.id AS manufacturer_id,
            t.id AS team_id,
            d.id AS driver_id,
            rr.start_position,
            rr.finish_position,
            (
                CAST(rr.start_position AS SIGNED) -
                CAST(rr.finish_position AS SIGNED)
            ) AS place_diff,
            rr.best_position,
            rr.worst_position,
            rr.average_position,
            rr.green_flag_passes,
            rr.green_flag_times_passed,
            (
                CAST(rr.green_flag_passes AS SIGNED) -
                CAST(rr.green_flag_times_passed AS SIGNED)
            ) AS green_flag_pass_diff,
            rr.quality_passes,
            ROUND(rr.quality_passes / NULLIF(rr.green_flag_passes, 0), 3) AS quality_passes_pct,
            rr.total_fastest_laps,
            ROUND(rr.total_fastest_laps / NULLIF(rrm.total_laps_completed, 0), 3) AS total_fastest_laps_pct,
            rr.total_top_15_laps,
            ROUND(rr.total_top_15_laps / NULLIF(rrm.total_laps_completed, 0), 3) AS total_top_15_laps_pct,
            rr.total_laps_led,
            ROUND(rr.total_laps_led / NULLIF(rrm.total_laps_completed, 0), 3) AS total_laps_led_pct,
            rr.total_laps_completed,
            ROUND(rr.total_laps_completed / NULLIF(rrm.total_laps_completed, 0), 3) AS total_laps_completed_pct,
            rr.driver_rating,
            rr.car_status,
            pt.avg_pitstop_crew_time,
            pt.avg_pitstop_driver_time,
            pt.total_pitstops,
            pt4.avg_4_pitstop_crew_time,
            pt4.avg_4_pitstop_driver_time,
            pt4.total_4_pitstops,
            pt2l.avg_2l_pitstop_crew_time,
            pt2l.avg_2l_pitstop_driver_time,
            pt2l.total_2l_pitstops,
            pt2r.avg_2r_pitstop_crew_time,
            pt2r.avg_2r_pitstop_driver_time,
            pt2r.total_2r_pitstops,
            IFNULL(pn.total_penalties, 0) AS total_penalties,
            rrm.total_laps_completed AS total_race_laps,
            rrm.total_laps_completed * tr.length AS total_race_miles
        FROM nascar.race_results rr
        JOIN weeks_races wr USING (race_id)
        JOIN weeks_race_results_max rrm USING (race_id)
        JOIN nascar.cars_drivers cd ON cd.id = rr.car_driver_id AND cd.deleted_at IS NULL
        JOIN nascar.cars c ON c.id = cd.car_id AND c.deleted_at IS NULL
        JOIN nascar.manufacturers m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
        JOIN nascar.teams t ON t.id = c.team_id AND t.deleted_at IS NULL
        JOIN nascar.drivers d ON d.id = cd.driver_id AND d.deleted_at IS NULL
        JOIN nascar.tracks tr ON wr.track_id = tr.id AND tr.deleted_at IS NULL
        LEFT JOIN weeks_races_pitstops_totals pt USING (car_driver_id)
        LEFT JOIN weeks_races_pitstops_4_totals pt4 USING (car_driver_id)
        LEFT JOIN weeks_races_pitstops_2l_totals pt2l USING (car_driver_id)
        LEFT JOIN weeks_races_pitstops_2r_totals pt2r USING (car_driver_id)
        LEFT JOIN weeks_races_penalties pn USING (car_driver_id)
        WHERE rr.deleted_at IS NULL
            AND rr.finish_position IS NOT NULL
    )
    SELECT
        rr.series_id AS series_id,
        rr.season_id AS season_id,
        rr.week_id AS week_id,
        rr.track_id AS track_id,
        rr.race_id AS race_id,
        rr.car_driver_id AS car_driver_id,
        rr.car_id AS car_id,
        rr.manufacturer_id AS manufacturer_id,
        rr.team_id AS team_id,
        rr.driver_id AS driver_id,
        rr.start_position AS r_start_position,
        rr.finish_position AS r_finish_position,
        rr.place_diff AS r_place_diff,
        rr.best_position AS r_best_position,
        rr.worst_position AS r_worst_position,
        rr.average_position AS r_average_position,
        rr.green_flag_passes AS r_green_flag_passes,
        rr.green_flag_times_passed AS r_green_flag_times_passed,
        rr.green_flag_pass_diff AS r_green_flag_pass_diff,
        rr.quality_passes AS r_quality_passes,
        rr.quality_passes_pct AS r_quality_passes_pct,
        rr.total_fastest_laps AS r_total_fastest_laps,
        rr.total_fastest_laps_pct AS r_total_fastest_laps_pct,
        rr.total_top_15_laps AS r_total_top_15_laps,
        rr.total_top_15_laps_pct AS r_total_top_15_laps_pct,
        rr.total_laps_led AS r_total_laps_led,
        rr.total_laps_led_pct AS r_total_laps_led_pct,
        rr.total_laps_completed AS r_total_laps_completed,
        rr.total_laps_completed_pct AS r_total_laps_completed_pct,
        rr.driver_rating AS r_driver_rating,
        rr.car_status AS r_car_status,
        rr.avg_pitstop_crew_time AS r_avg_pitstop_crew_time,
        rr.avg_pitstop_driver_time AS r_avg_pitstop_driver_time,
        rr.total_pitstops AS r_total_pitstops,
        rr.avg_4_pitstop_crew_time AS r_avg_4_pitstop_crew_time,
        rr.avg_4_pitstop_driver_time AS r_avg_4_pitstop_driver_time,
        rr.total_4_pitstops AS r_total_4_pitstops,
        rr.avg_2l_pitstop_crew_time AS r_avg_2l_pitstop_crew_time,
        rr.avg_2l_pitstop_driver_time AS r_avg_2l_pitstop_driver_time,
        rr.total_2l_pitstops AS r_total_2l_pitstops,
        rr.avg_2r_pitstop_crew_time AS r_avg_2r_pitstop_crew_time,
        rr.avg_2r_pitstop_driver_time AS r_avg_2r_pitstop_driver_time,
        rr.total_2r_pitstops AS r_total_2r_pitstops,
        rr.total_penalties AS r_total_penalties,
        rr.total_race_laps AS r_total_race_laps,
        rr.total_race_miles AS r_total_race_miles,
        qr.finish_position AS q_finish_position,
        qr.best_speed AS q_best_speed,
        qr.best_time AS q_best_time,
        prt.min_finish_position AS pt_min_finish_position,
        prt.max_finish_position AS pt_max_finish_position,
        prt.avg_finish_position AS pt_avg_finish_position,
        prt.min_best_speed AS pt_min_best_speed,
        prt.max_best_speed AS pt_max_best_speed,
        prt.avg_best_speed AS pt_avg_best_speed,
        prt.min_best_time AS pt_min_best_time,
        prt.max_best_time AS pt_max_best_time,
        prt.avg_best_time AS pt_avg_best_time,
        prt.min_total_laps AS pt_min_total_laps,
        prt.max_total_laps AS pt_max_total_laps,
        prt.avg_total_laps AS pt_avg_total_laps,
        prt.sum_total_laps AS pt_sum_total_laps,
        prt.min_5_lap_average_time AS pt_min_5_lap_average_time,
        prt.max_5_lap_average_time AS pt_max_5_lap_average_time,
        prt.avg_5_lap_average_time AS pt_avg_5_lap_average_time,
        prt.min_10_lap_average_time AS pt_min_10_lap_average_time,
        prt.max_10_lap_average_time AS pt_max_10_lap_average_time,
        prt.avg_10_lap_average_time AS pt_avg_10_lap_average_time,
        prt.min_20_lap_average_time AS pt_min_20_lap_average_time,
        prt.max_20_lap_average_time AS pt_max_20_lap_average_time,
        prt.avg_20_lap_average_time AS pt_avg_20_lap_average_time,
        prt.min_25_lap_average_time AS pt_min_25_lap_average_time,
        prt.max_25_lap_average_time AS pt_max_25_lap_average_time,
        prt.avg_25_lap_average_time AS pt_avg_25_lap_average_time,
        prt.min_30_lap_average_time AS pt_min_30_lap_average_time,
        prt.max_30_lap_average_time AS pt_max_30_lap_average_time,
        prt.avg_30_lap_average_time AS pt_avg_30_lap_average_time,
        prt.min_10_lap_average_speed AS pt_min_10_lap_average_speed,
        prt.max_10_lap_average_speed AS pt_max_10_lap_average_speed,
        prt.avg_10_lap_average_speed AS pt_avg_10_lap_average_speed,
        prt.min_10_lap_start AS pt_min_10_lap_start,
        prt.max_10_lap_start AS pt_max_10_lap_start,
        prt.avg_10_lap_start AS pt_avg_10_lap_start,
        prt.min_10_lap_end AS pt_min_10_lap_end,
        prt.max_10_lap_end AS pt_max_10_lap_end,
        prt.avg_10_lap_end AS pt_avg_10_lap_end,
        prf.finish_position AS pf_finish_position,
        prf.best_speed AS pf_best_speed,
        prf.best_time AS pf_best_time,
        prf.total_laps AS pf_total_laps,
        prf.5_lap_average_time AS pf_5_lap_average_time,
        prf.10_lap_average_time AS pf_10_lap_average_time,
        prf.20_lap_average_time AS pf_20_lap_average_time,
        prf.25_lap_average_time AS pf_25_lap_average_time,
        prf.30_lap_average_time AS pf_30_lap_average_time,
        prf.10_lap_average_speed AS pf_10_lap_average_speed,
        prf.10_lap_start AS pf_10_lap_start,
        prf.10_lap_end AS pf_10_lap_end
    FROM weeks_race_results rr
    LEFT JOIN weeks_qualifying_results qr USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    LEFT JOIN weeks_practices_results_total prt USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    LEFT JOIN weeks_practices_results_final prf USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    ORDER BY rr.series_id, rr.season_id, rr.week_id, rr.finish_position, rr.start_position
    ;
END$$
DELIMITER ;
