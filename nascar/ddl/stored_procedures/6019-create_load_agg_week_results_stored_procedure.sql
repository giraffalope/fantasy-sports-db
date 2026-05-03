-- load_agg_week_results: stored procedure used by NASCAR hourly aggregate backfill pipeline.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.
-- AI GENERATED QUERY FUCKED UP, DO NOT TRUST. REVIEW CAREFULLY BEFORE RUNNING.
DROP PROCEDURE IF EXISTS `load_agg_week_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_results`()
    COMMENT 'Load weekly aggregate race features for weeks that have race results but no active agg_week_results rows, or with active rows having NULL finish position.'
BEGIN
    insert into `nascar`.`agg_week_results` (
        series_id,
        season_id,
        week_id,
        track_id,
        race_id,
        car_driver_id,
        car_id,
        manufacturer_id,
        car_generation_id,
        car_generation_model_id,
        team_id,
        driver_id,
        r_start_position,
        r_finish_position,
        r_place_diff,
        r_best_position,
        r_worst_position,
        r_average_position,
        r_green_flag_passes,
        r_green_flag_times_passed,
        r_green_flag_pass_diff,
        r_quality_passes,
        r_quality_passes_pct,
        r_total_fastest_laps,
        r_total_fastest_laps_pct,
        r_total_top_15_laps,
        r_total_top_15_laps_pct,
        r_total_laps_led,
        r_total_laps_led_pct,
        r_total_laps_completed,
        r_total_laps_completed_pct,
        r_driver_rating,
        r_car_status,
        r_avg_pitstop_crew_time,
        r_avg_pitstop_driver_time,
        r_total_pitstops,
        r_avg_4_pitstop_crew_time,
        r_avg_4_pitstop_driver_time,
        r_total_4_pitstops,
        r_avg_2l_pitstop_crew_time,
        r_avg_2l_pitstop_driver_time,
        r_total_2l_pitstops,
        r_avg_2r_pitstop_crew_time,
        r_avg_2r_pitstop_driver_time,
        r_total_2r_pitstops,
        r_total_penalties,
        r_total_race_laps,
        r_total_race_miles,
        q_finish_position,
        q_best_speed,
        q_best_time,
        pt_min_finish_position,
        pt_max_finish_position,
        pt_avg_finish_position,
        pt_min_best_speed,
        pt_max_best_speed,
        pt_avg_best_speed,
        pt_min_best_time,
        pt_max_best_time,
        pt_avg_best_time,
        pt_min_total_laps,
        pt_max_total_laps,
        pt_avg_total_laps,
        pt_sum_total_laps,
        pt_min_5_lap_average_time,
        pt_max_5_lap_average_time,
        pt_avg_5_lap_average_time,
        pt_min_10_lap_average_time,
        pt_max_10_lap_average_time,
        pt_avg_10_lap_average_time,
        pt_min_20_lap_average_time,
        pt_max_20_lap_average_time,
        pt_avg_20_lap_average_time,
        pt_min_25_lap_average_time,
        pt_max_25_lap_average_time,
        pt_avg_25_lap_average_time,
        pt_min_30_lap_average_time,
        pt_max_30_lap_average_time,
        pt_avg_30_lap_average_time,
        pt_min_10_lap_average_speed,
        pt_max_10_lap_average_speed,
        pt_avg_10_lap_average_speed,
        pt_min_10_lap_start,
        pt_max_10_lap_start,
        pt_avg_10_lap_start,
        pt_min_10_lap_end,
        pt_max_10_lap_end,
        pt_avg_10_lap_end,
        pf_finish_position,
        pf_best_speed,
        pf_best_time,
        pf_total_laps,
        pf_5_lap_average_time,
        pf_10_lap_average_time,
        pf_20_lap_average_time,
        pf_25_lap_average_time,
        pf_30_lap_average_time,
        pf_10_lap_average_speed,
        pf_10_lap_start,
        pf_10_lap_end
    )
        with
        week_race_results as (
            select distinct
                r.week_id
            from nascar.race_results rr
            join nascar.races r on rr.race_id = r.id and r.deleted_at is null
            join nascar.weeks w on r.week_id = w.id and w.deleted_at is null
            where rr.deleted_at is null
        ),
        -- want rows that don't have finish position set to rerun
        week_results as (
            select distinct
                awr.week_id
            from nascar.agg_week_results awr
            where awr.deleted_at is null and awr.r_finish_position is not null
        ),
        week_results_to_update as (
            select week_id
            from week_race_results
            except
            select week_id
            from week_results
        ),
        weeks as (
            select 
                sr.id as series_id,
                s.id as season_id,
                w.id as week_id,
                t.id as track_id
            from week_results_to_update wrtu
            join nascar.weeks w on wrtu.week_id = w.id and w.deleted_at is null
            join nascar.seasons s on w.season_id = s.id and s.deleted_at is null
            join nascar.series sr on s.series_id = sr.id and sr.deleted_at is null
            join nascar.tracks t on w.track_id = t.id and t.deleted_at is null
        ),
        seasons as (
            select distinct
                series_id,
                season_id
            from weeks w
        ),
        weeks_practices as (
            select distinct
                w.series_id,
                w.season_id,
                w.week_id,
                w.track_id,
                p.id as practice_id,
                p.number as practice_number
            from weeks w
            join nascar.practices p on p.week_id = w.week_id and p.deleted_at is null
        ),
        weeks_qualifyings as (
            select distinct
                w.series_id,
                w.season_id,
                w.week_id,
                w.track_id,
                q.id as qualifying_id
            from weeks w
            join nascar.qualifyings q on q.week_id = w.week_id and q.deleted_at is null
        ),
        weeks_races as (
            select distinct
                w.series_id,
                w.season_id,
                w.week_id,
                w.track_id,
                r.id as race_id
            from weeks w
            join nascar.races r on r.week_id = w.week_id and r.deleted_at is null
        ),
        weeks_races_penalties as (
            select
                wr.series_id,
                wr.season_id,
                wr.week_id,
                wr.track_id,
                wr.race_id,
                pn.car_driver_id,
                count(*) as total_penalties
            from weeks_races wr
            join nascar.penalties pn on wr.race_id = pn.race_id and pn.deleted_at is null
            group by wr.series_id, wr.season_id, wr.week_id, wr.track_id, wr.race_id, pn.car_driver_id
        ),
        weeks_races_pitstops as (
            select
                wr.series_id,
                wr.season_id,
                wr.week_id,
                wr.track_id,
                wr.race_id,
                p.car_driver_id as car_driver_id,
                p.crew_time,
                p.driver_time,
                p.type
            from weeks_races wr
            join nascar.pitstops p on wr.race_id = p.race_id and p.deleted_at is null
        ),
        weeks_races_pitstops_totals as (
            select
                wrp.series_id,
                wrp.season_id,
                wrp.week_id,
                wrp.track_id,
                wrp.race_id,
                wrp.car_driver_id,
                sec_to_time(round(avg(time_to_sec(wrp.crew_time)), 3)) as avg_pitstop_crew_time,
                sec_to_time(round(avg(time_to_sec(wrp.driver_time)), 3)) as avg_pitstop_driver_time,
                count(*) as total_pitstops
            from weeks_races_pitstops wrp
            group by wrp.series_id, wrp.season_id, wrp.week_id, wrp.track_id, wrp.race_id, wrp.car_driver_id
        ),
        weeks_races_pitstops_4_totals as (
            select
                wrp.series_id,
                wrp.season_id,
                wrp.week_id,
                wrp.track_id,
                wrp.race_id,
                wrp.car_driver_id,
                sec_to_time(round(avg(time_to_sec(wrp.crew_time)), 3)) AS avg_4_pitstop_crew_time,
                sec_to_time(round(avg(time_to_sec(wrp.driver_time)), 3)) AS avg_4_pitstop_driver_time,
                count(*) as total_4_pitstops
            from weeks_races_pitstops wrp
            where wrp.type = 'FOUR_WHEEL_CHANGE'
            group by wrp.series_id, wrp.season_id, wrp.week_id, wrp.track_id, wrp.race_id, wrp.car_driver_id
        ),
        weeks_races_pitstops_2l_totals as (
            select
                wrp.series_id,
                wrp.season_id,
                wrp.week_id,
                wrp.track_id,
                wrp.race_id,
                wrp.car_driver_id,
                sec_to_time(round(avg(time_to_sec(wrp.crew_time)), 3)) AS avg_2l_pitstop_crew_time,
                sec_to_time(round(avg(time_to_sec(wrp.driver_time)), 3)) AS avg_2l_pitstop_driver_time,
                count(*) as total_2l_pitstops
            from weeks_races_pitstops wrp
            where wrp.type = 'TWO_WHEEL_CHANGE_LEFT'
            group by wrp.series_id, wrp.season_id, wrp.week_id, wrp.track_id, wrp.race_id, wrp.car_driver_id
        ),
        weeks_races_pitstops_2r_totals as (
            select
                wrp.series_id,
                wrp.season_id,
                wrp.week_id,
                wrp.track_id,
                wrp.race_id,
                wrp.car_driver_id,
                sec_to_time(round(avg(time_to_sec(wrp.crew_time)), 3)) as avg_2r_pitstop_crew_time,
                sec_to_time(round(avg(time_to_sec(wrp.driver_time)), 3)) as avg_2r_pitstop_driver_time,
                count(*) as total_2r_pitstops
            from weeks_races_pitstops wrp
            where wrp.type = 'TWO_WHEEL_CHANGE_RIGHT'
            group by wrp.series_id, wrp.season_id, wrp.week_id, wrp.track_id, wrp.race_id, wrp.car_driver_id
        ),
        season_car_generations_models as (
            select
                s.season_id,
                cgs.car_generation_id,
                cgms.car_generation_model_id,
                cgms.manufacturer_id
            from seasons s
            left join nascar.car_generations_seasons cgs on s.season_id = cgs.season_id and cgs.deleted_at is null
            left join nascar.car_generation_models_seasons cgms on cgs.id = cgms.car_generations_seasons_id and cgms.deleted_at is null
        ),
        weeks_practices_results as (
            select distinct
                wp.series_id,
                wp.season_id,
                wp.week_id,
                wp.track_id,
                wp.practice_id,
                wp.practice_number,
                pr.car_driver_id,
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
            from nascar.practice_results pr
            join weeks_practices wp using (practice_id)
            join nascar.cars_drivers cd on cd.id = pr.car_driver_id and cd.deleted_at is null
            join nascar.cars c on c.id = cd.car_id and c.deleted_at is null
            join nascar.drivers d on d.id = cd.driver_id and d.deleted_at is null
            left join nascar.manufacturers m on m.id = c.manufacturer_id and m.deleted_at is null
            left join nascar.teams t on t.id = c.team_id and t.deleted_at is null
            where pr.deleted_at is null
                and pr.best_speed is not null
                and pr.best_time is not null
        ),
        weeks_practices_results_final as (
            select wpr.*
            from weeks_practices_results wpr
            join (
                select
                    series_id,
                    season_id,
                    week_id,
                    track_id,
                    max(practice_number) as practice_number
                from weeks_practices_results
                group by series_id, season_id, week_id, track_id
            ) fp
                on fp.series_id = wpr.series_id
                and fp.season_id = wpr.season_id
                and fp.week_id = wpr.week_id
                and fp.track_id = wpr.track_id
                and fp.practice_number = wpr.practice_number
        ),
        weeks_practices_results_total as (
            select
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
                min(finish_position) as min_finish_position,
                max(finish_position) as max_finish_position,
                round(avg(finish_position), 3) as avg_finish_position,
                min(best_speed) as min_best_speed,
                max(best_speed) as max_best_speed,
                round(AVG(best_speed), 3) as avg_best_speed,
                min(best_time) as min_best_time,
                max(best_time) as max_best_time,
                round(AVG(best_time), 3) as avg_best_time,
                min(total_laps) as min_total_laps,
                max(total_laps) as max_total_laps,
                round(AVG(total_laps), 3) as avg_total_laps,
                sum(total_laps) as sum_total_laps,
                min(5_lap_average_time) as min_5_lap_average_time,
                max(5_lap_average_time) as max_5_lap_average_time,
                round(AVG(5_lap_average_time), 3) as avg_5_lap_average_time,
                min(10_lap_average_time) as min_10_lap_average_time,
                max(10_lap_average_time) as max_10_lap_average_time,
                round(AVG(10_lap_average_time), 3) as avg_10_lap_average_time,
                min(20_lap_average_time) as min_20_lap_average_time,
                max(20_lap_average_time) as max_20_lap_average_time,
                round(AVG(20_lap_average_time), 3) as avg_20_lap_average_time,
                min(25_lap_average_time) as min_25_lap_average_time,
                max(25_lap_average_time) as max_25_lap_average_time,
                round(AVG(25_lap_average_time), 3) as avg_25_lap_average_time,
                min(30_lap_average_time) as min_30_lap_average_time,
                max(30_lap_average_time) as max_30_lap_average_time,
                round(AVG(30_lap_average_time), 3) as avg_30_lap_average_time,
                min(10_lap_average_speed) as min_10_lap_average_speed,
                max(10_lap_average_speed) as max_10_lap_average_speed,
                round(AVG(10_lap_average_speed), 3) as avg_10_lap_average_speed,
                min(10_lap_start) as min_10_lap_start,
                max(10_lap_start) as max_10_lap_start,
                round(AVG(10_lap_start), 3) as avg_10_lap_start,
                min(10_lap_end) as min_10_lap_end,
                max(10_lap_end) as max_10_lap_end,
                round(AVG(10_lap_end), 3) as avg_10_lap_end
            from weeks_practices_results
            group by series_id, season_id, week_id, track_id, car_driver_id, car_id, manufacturer_id, team_id, driver_id
        ),
        weeks_qualifying_results as (
            select distinct
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
            join weeks_qualifyings wq using (qualifying_id)
            join nascar.cars_drivers cd on cd.id = qr.car_driver_id and cd.deleted_at is null
            join nascar.cars c on c.id = cd.car_id and c.deleted_at is null
            join nascar.drivers d on d.id = cd.driver_id and d.deleted_at is null
            left join nascar.manufacturers m on m.id = c.manufacturer_id and m.deleted_at is null
            left join nascar.teams t on t.id = c.team_id and t.deleted_at is null
            where qr.deleted_at is null
                and qr.finish_position is not null
                and qr.best_speed is not null
                and qr.best_time is not null
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
                scgm.car_generation_id,
                scgm.car_generation_model_id,
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
            join nascar.cars_drivers cd on cd.id = rr.car_driver_id and cd.deleted_at is null
            join nascar.cars c on c.id = cd.car_id and c.deleted_at is null
            join nascar.drivers d on d.id = cd.driver_id and d.deleted_at is null
            join nascar.tracks tr on wr.track_id = tr.id and tr.deleted_at is null
            left join nascar.manufacturers m on m.id = c.manufacturer_id and m.deleted_at is null
            left join season_car_generations_models scgm on scgm.season_id = wr.season_id and scgm.manufacturer_id = m.id
            left join nascar.teams t on t.id = c.team_id and t.deleted_at is null
            LEFT JOIN weeks_races_pitstops_totals pt USING (race_id, car_driver_id)
            LEFT JOIN weeks_races_pitstops_4_totals pt4 USING (race_id, car_driver_id)
            LEFT JOIN weeks_races_pitstops_2l_totals pt2l USING (race_id, car_driver_id)
            LEFT JOIN weeks_races_pitstops_2r_totals pt2r USING (race_id, car_driver_id)
            LEFT JOIN weeks_races_penalties pn USING (race_id, car_driver_id)
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
            rr.car_generation_id,
            rr.car_generation_model_id,
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
