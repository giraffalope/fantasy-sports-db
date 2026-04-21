DROP PROCEDURE IF EXISTS `nascar`.`week_results`;

DELIMITER //

CREATE PROCEDURE `nascar`.`week_results`(
    IN `r_series_id` BIGINT UNSIGNED,
    IN `r_season_id` BIGINT UNSIGNED,
    IN `r_week_id` BIGINT UNSIGNED
)
COMMENT 'Aggregate statistics for a specific race week in the NASCAR series, including practices, qualifying, race results, as well as penalties and pitstops.'
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
    weeks AS (
        SELECT DISTINCT
            s.series_id,
            s.season_id,
            w.id AS week_id,
            w.track_id AS track_id
        FROM nascar.weeks w
        JOIN seasons s USING (season_id)
        WHERE w.deleted_at IS NULL
            AND w.id = r_week_id
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
        SELECT *
        FROM weeks_practices_results
        JOIN (
            SELECT MAX(practice_number) as practice_number
            FROM weeks_practices_results
        ) fp USING (practice_number)
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
        JOIN  weeks_races wr USING (race_id)
        GROUP BY rr.race_id
    ),
    weeks_race_results AS (
        SELECT
            wr.series_id,
            wr.season_id,
            wr.week_id ,
            wr.track_id,
            wr.race_id,
            rr.car_driver_id,
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
            ROUND(rr.quality_passes / rr.green_flag_passes, 3) AS quality_passes_pct,
            rr.total_fastest_laps,
            ROUND(rr.total_fastest_laps / rrm.total_laps_completed, 3) AS total_fastest_laps_pct,
            rr.total_top_15_laps,
            ROUND(rr.total_top_15_laps / rrm.total_laps_completed, 3) AS total_top_15_laps_pct,
            rr.total_laps_led,
            ROUND(rr.total_laps_led / rrm.total_laps_completed, 3) AS total_laps_led_pct,
            rr.total_laps_completed,
            ROUND(rr.total_laps_completed / rrm.total_laps_completed, 3) AS total_laps_completed_pct,
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
        rr.series_id as series_id,
        rr.season_id as season_id,
        rr.week_id as week_id,
        rr.track_id as track_id,
        rr.race_id as race_id,
        rr.car_driver_id as car_driver_id,
        rr.car_id as car_id,
        rr.manufacturer_id as manufacturer_id,
        rr.team_id as team_id,
        rr.driver_id as driver_id,
        rr.start_position as r_start_position,
        rr.finish_position as r_finish_position,
        rr.best_position as r_best_position,
        rr.worst_position as r_worst_position,
        rr.average_position as r_average_position,
        rr.green_flag_passes as r_green_flag_passes,
        rr.green_flag_times_passed as r_green_flag_times_passed,
        rr.green_flag_pass_diff as r_green_flag_pass_diff,
        rr.quality_passes as r_quality_passes,
        rr.quality_passes_pct as r_quality_passes_pct,
        rr.total_fastest_laps as r_total_fastest_laps,
        rr.total_fastest_laps_pct as r_total_fastest_laps_pct,
        rr.total_top_15_laps as r_total_top_15_laps,
        rr.total_top_15_laps_pct as r_total_top_15_laps_pct,
        rr.total_laps_led as r_total_laps_led,
        rr.total_laps_led_pct as r_total_laps_led_pct,
        rr.total_laps_completed as r_total_laps_completed,
        rr.total_laps_completed_pct as r_total_laps_completed_pct,
        rr.driver_rating as r_driver_rating,
        rr.car_status as r_car_status,
        rr.avg_pitstop_crew_time as r_avg_pitstop_crew_time,
        rr.avg_pitstop_driver_time as r_avg_pitstop_driver_time,
        rr.total_pitstops as r_total_pitstops,
		rr.avg_4_pitstop_crew_time as r_avg_4_pitstop_crew_time,
        rr.avg_4_pitstop_driver_time as r_avg_4_pitstop_driver_time,
        rr.total_4_pitstops as r_total_4_pitstops,
		rr.avg_2l_pitstop_crew_time as r_avg_2l_pitstop_crew_time,
        rr.avg_2l_pitstop_driver_time as r_avg_2l_pitstop_driver_time,
        rr.total_2l_pitstops as r_total_2l_pitstops,
		rr.avg_2r_pitstop_crew_time as r_avg_2r_pitstop_crew_time,
        rr.avg_2r_pitstop_driver_time as r_avg_2r_pitstop_driver_time,
        rr.total_2r_pitstops as r_total_2r_pitstops,
        rr.total_penalties as r_total_penalties,
        rr.total_race_laps as r_total_race_laps,
        rr.total_race_miles as r_total_race_miles,
        qr.finish_position as q_finish_position,
        qr.best_speed as q_best_speed,
        qr.best_time as q_best_time,
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
        prf.finish_position as pf_finish_position,
        prf.best_speed as pf_best_speed,
        prf.best_time as pf_best_time,
        prf.total_laps as pf_total_laps,
        prf.5_lap_average_time as pf_5_lap_average_time,
        prf.10_lap_average_time as pf_10_lap_average_time,
        prf.20_lap_average_time as pf_20_lap_average_time,
        prf.25_lap_average_time as pf_25_lap_average_time,
        prf.30_lap_average_time as pf_30_lap_average_time,
        prf.10_lap_average_speed as pf_10_lap_average_speed,
        prf.10_lap_start as pf_10_lap_start,
        prf.10_lap_end as pf_10_lap_end
    FROM weeks_race_results rr
    LEFT JOIN weeks_qualifying_results qr USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    LEFT JOIN weeks_practices_results_total prt USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    LEFT JOIN weeks_practices_results_final prf USING (series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id)
    ;
END //

DELIMITER ;
