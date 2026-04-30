-- ingestion_overview: view used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP VIEW IF EXISTS `ingestion_overview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `ingestion_overview` AS
SELECT
    s.name AS series_name,
    se.year AS year,
    w.number AS week_number,
    w.season_number AS season_number,
    t.name AS track_name,
    w.race_name AS race_name,
    w.event_type AS event_type,
    w.scheduled_start AS scheduled_start,
    w.id AS week_id,
    COUNT(DISTINCT p.id) AS total_practices,
    COUNT(DISTINCT q.id) AS total_qualifyings,
    COUNT(DISTINCT r.id) AS total_races,
    COUNT(DISTINCT pr.id) AS total_practice_results,
    COUNT(DISTINCT qr.id) AS total_qualifying_results,
    COUNT(DISTINCT rr.id) AS total_race_results
FROM series s
JOIN seasons se ON se.series_id = s.id
JOIN weeks w ON w.season_id = se.id
JOIN tracks t ON t.id = w.track_id
LEFT JOIN practices p ON p.week_id = w.id
LEFT JOIN qualifyings q ON q.week_id = w.id
LEFT JOIN races r ON r.week_id = w.id
LEFT JOIN practice_results pr ON pr.practice_id = p.id
LEFT JOIN qualifying_results qr ON qr.qualifying_id = q.id
LEFT JOIN race_results rr ON rr.race_id = r.id
GROUP BY
    s.name,
    se.year,
    w.number,
    w.season_number,
    t.name,
    w.race_name,
    w.event_type,
    w.scheduled_start,
    w.id;
