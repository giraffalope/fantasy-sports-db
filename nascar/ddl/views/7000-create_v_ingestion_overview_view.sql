-- ingestion_overview: view used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP VIEW IF EXISTS `v_ingestion_overview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ingestion_overview` AS
WITH schedule AS (
    SELECT
        s.name as series_name,
        se.year,
        w.number,
        w.season_number,
        t.name AS track_name,
        w.race_name,
        w.event_type,
        w.scheduled_start,
        w.id AS week_id
    FROM nascar.series s
    JOIN nascar.seasons se ON s.id = se.series_id
    JOIN nascar.weeks w ON se.id = w.season_id
    JOIN nascar.tracks t ON w.track_id = t.id
    ORDER BY se.year, w.number, w.season_number
),
practices AS (
    SELECT DISTINCT s.week_id, pr.practice_id
    FROM schedule s
    RIGHT JOIN nascar.practices p USING (week_id)
    RIGHT JOIN nascar.practice_results pr ON p.id = pr.practice_id
    GROUP BY 1, 2
),
total_practices AS (
    SELECT p.week_id, COUNT(*) AS total_practices
    FROM practices p
    GROUP BY 1
),
total_practices_results AS (
    SELECT p.week_id, COUNT(*) AS total_practices_results
    FROM practices p
    RIGHT JOIN nascar.practice_results pr ON p.practice_id = pr.practice_id
    GROUP BY 1
),
total_bad_data_practices_results AS (
    SELECT p.week_id, COUNT(*) AS total_bad_data_practices_results
    FROM practices p
    RIGHT JOIN nascar.practice_results pr ON p.practice_id = pr.practice_id
    WHERE pr.best_speed = 0 OR pr.best_time = '00:00:00.000' OR pr.best_speed IS NULL OR pr.best_time IS NULL
    GROUP BY 1
),
total_bad_car_driver_practices_results AS (
    SELECT p.week_id, GROUP_CONCAT(DISTINCT pr.car_driver_id ORDER BY pr.car_driver_id ASC) AS bad_car_driver_practices_results
    FROM practices p
    RIGHT JOIN nascar.practice_results pr ON p.practice_id = pr.practice_id
    LEFT JOIN nascar.cars_drivers cd ON pr.car_driver_id = cd.id
    LEFT JOIN nascar.cars c ON cd.car_id = c.id
    LEFT JOIN nascar.manufacturers m ON c.manufacturer_id = m.id
    LEFT JOIN nascar.teams t ON c.team_id = t.id
    LEFT JOIN nascar.drivers d ON cd.driver_id = d.id
    WHERE cd.id IS NULL OR c.id IS NULL OR m.id IS NULL OR t.id IS NULL OR d.id IS NULL
    GROUP BY 1
),
qualifyings AS (
    SELECT DISTINCT s.week_id, qr.qualifying_id
    FROM schedule s
    RIGHT JOIN nascar.qualifyings q USING (week_id)
    RIGHT JOIN nascar.qualifying_results qr ON q.id = qr.qualifying_id
    GROUP BY 1, 2
),
total_qualifyings AS (
    SELECT q.week_id, COUNT(*) AS total_qualifyings
    FROM qualifyings q
    GROUP BY 1
),
total_qualifying_results AS (
    SELECT q.week_id, COUNT(*) AS total_qualifying_results
    FROM qualifyings q
    RIGHT JOIN nascar.qualifying_results qr ON q.qualifying_id = qr.qualifying_id
    GROUP BY 1
),
total_bad_data_qualifying_results AS (
    SELECT q.week_id, COUNT(*) AS total_bad_data_qualifying_results
    FROM qualifyings q
    RIGHT JOIN nascar.qualifying_results qr ON q.qualifying_id = qr.qualifying_id
    WHERE qr.best_speed = 0
       OR qr.best_time = '00:00:00.000'
       OR qr.best_speed IS NULL
       OR qr.best_time IS NULL
    GROUP BY 1
),
total_bad_car_driver_qualifying_results AS (
    SELECT q.week_id, GROUP_CONCAT(DISTINCT qr.car_driver_id ORDER BY qr.car_driver_id ASC) AS bad_car_driver_qualifying_results
    FROM qualifyings q
    RIGHT JOIN nascar.qualifying_results qr ON q.qualifying_id = qr.qualifying_id
    LEFT JOIN nascar.cars_drivers cd ON qr.car_driver_id = cd.id
    LEFT JOIN nascar.cars c ON cd.car_id = c.id
    LEFT JOIN nascar.manufacturers m ON c.manufacturer_id = m.id
    LEFT JOIN nascar.teams t ON c.team_id = t.id
    LEFT JOIN nascar.drivers d ON cd.driver_id = d.id
    WHERE cd.id IS NULL OR c.id IS NULL OR m.id IS NULL OR t.id IS NULL OR d.id IS NULL
    GROUP BY 1
),
races AS (
    SELECT DISTINCT s.week_id, rr.race_id
    FROM schedule s
    RIGHT JOIN nascar.races r USING (week_id)
    RIGHT JOIN nascar.race_results rr ON r.id = rr.race_id
    GROUP BY 1, 2
),
total_races AS (
    SELECT r.week_id, COUNT(*) AS total_races
    FROM races r
    GROUP BY 1
),
total_race_results AS (
    SELECT r.week_id, COUNT(*) AS total_race_results
    FROM races r
    RIGHT JOIN nascar.race_results rr ON r.race_id = rr.race_id
    GROUP BY 1
),
total_bad_data_race_results AS (
    SELECT r.week_id, COUNT(*) AS total_bad_data_race_results
    FROM races r
    RIGHT JOIN nascar.race_results rr ON r.race_id = rr.race_id
    WHERE rr.car_driver_id IS NULL
       OR rr.start_position IS NULL
       OR rr.finish_position IS NULL
    GROUP BY 1
),
total_bad_car_driver_race_results AS (
    SELECT r.week_id, GROUP_CONCAT(DISTINCT rr.car_driver_id ORDER BY rr.car_driver_id ASC) AS bad_car_driver_race_results
    FROM races r
    RIGHT JOIN nascar.race_results rr ON r.race_id = rr.race_id
    LEFT JOIN nascar.cars_drivers cd ON rr.car_driver_id = cd.id
    LEFT JOIN nascar.cars c ON cd.car_id = c.id
    LEFT JOIN nascar.manufacturers m ON c.manufacturer_id = m.id
    LEFT JOIN nascar.teams t ON c.team_id = t.id
    LEFT JOIN nascar.drivers d ON cd.driver_id = d.id
    WHERE cd.id IS NULL OR c.id IS NULL OR m.id IS NULL OR t.id IS NULL OR d.id IS NULL
    GROUP BY 1
),
penalties AS (
    SELECT DISTINCT p.race_id, r.week_id
    FROM nascar.penalties p
    RIGHT JOIN races r USING (race_id)
),
pitstops AS (
    SELECT DISTINCT p.race_id, r.week_id
    FROM nascar.pitstops p
    RIGHT JOIN races r USING (race_id)
),
draftkings_salaries AS (
    SELECT DISTINCT r.week_id, ds.id
    FROM nascar.dfs_salaries ds
    JOIN nascar.races r ON r.id = ds.race_id
    JOIN nascar.dfs d ON d.id = ds.dfs_id
    WHERE d.name = 'DraftKings'
),
total_draftkings_salaries AS (
    SELECT week_id, COUNT(*) AS total_draftkings_salaries
    FROM draftkings_salaries
    GROUP BY 1
),
fanduel_salaries AS (
    SELECT DISTINCT r.week_id, ds.id
    FROM nascar.dfs_salaries ds
    JOIN nascar.races r ON r.id = ds.race_id
    JOIN nascar.dfs d ON d.id = ds.dfs_id
    WHERE d.name = 'FanDuel'
),
total_fanduel_salaries AS (
    SELECT week_id, COUNT(*) AS total_fanduel_salaries
    FROM fanduel_salaries
    GROUP BY 1
)
SELECT
    s.*,
    IFNULL(tp.total_practices, 0) AS total_practices,
    IFNULL(tpr.total_practices_results, 0) AS total_practices_results,
    IFNULL(tbdpr.total_bad_data_practices_results, 0) AS total_bad_data_practices_results,
    tbcpr.bad_car_driver_practices_results AS bad_car_driver_practices_results,
    IFNULL(tq.total_qualifyings, 0) AS total_qualifyings,
    IFNULL(tqr.total_qualifying_results, 0) AS total_qualifying_results,
    IFNULL(tbdqr.total_bad_data_qualifying_results, 0) AS total_bad_data_qualifying_results,
    tbcqr.bad_car_driver_qualifying_results AS bad_car_driver_qualifying_results,
    IFNULL(tr.total_races, 0) AS total_races,
    IFNULL(trr.total_race_results, 0) AS total_race_results,
    IFNULL(tbdrr.total_bad_data_race_results, 0) AS total_bad_data_race_results,
    tbcrr.bad_car_driver_race_results AS bad_car_driver_race_results,
    IFNULL(IF(pen.race_id, TRUE, FALSE), FALSE) AS has_penalty_data,
    IFNULL(IF(pit.race_id, TRUE, FALSE), FALSE) AS has_pitstop_data,
    IFNULL(tds.total_draftkings_salaries, 0) AS total_draftkings_salaries,
    IFNULL(tfs.total_fanduel_salaries, 0) AS total_fanduel_salaries
FROM schedule s
LEFT JOIN total_practices tp USING (week_id)
LEFT JOIN total_practices_results tpr USING (week_id)
LEFT JOIN total_bad_data_practices_results tbdpr USING (week_id)
LEFT JOIN total_bad_car_driver_practices_results tbcpr USING (week_id)
LEFT JOIN total_qualifyings tq USING (week_id)
LEFT JOIN total_qualifying_results tqr USING (week_id)
LEFT JOIN total_bad_data_qualifying_results tbdqr USING (week_id)
LEFT JOIN total_bad_car_driver_qualifying_results tbcqr USING (week_id)
RIGHT JOIN total_races tr USING (week_id)
LEFT JOIN total_race_results trr USING (week_id)
LEFT JOIN total_bad_data_race_results tbdrr USING (week_id)
LEFT JOIN total_bad_car_driver_race_results tbcrr USING (week_id)
LEFT JOIN total_draftkings_salaries tds USING (week_id)
LEFT JOIN total_fanduel_salaries tfs USING (week_id)
LEFT JOIN penalties pen USING (week_id)
LEFT JOIN pitstops pit USING (week_id)
ORDER BY year, number;
