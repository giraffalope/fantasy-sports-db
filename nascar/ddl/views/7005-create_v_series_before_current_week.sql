-- v_series_before_current_week: P/Q/R-active weeks strictly before each series' current week.
-- Depends on v_series_current_week. Ordering matches current week:
-- (season_year, week_number, week_season_number).

DROP VIEW IF EXISTS `v_series_before_current_week`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_series_before_current_week` AS
WITH weeks_with_activity AS (
    SELECT
        s.id AS series_id,
        s.name AS series_name,
        se.id AS season_id,
        se.year AS season_year,
        w.id AS week_id,
        w.number AS week_number,
        w.season_number AS week_season_number
    FROM nascar.series s
    JOIN nascar.seasons se ON s.id = se.series_id AND se.deleted_at IS NULL
    JOIN nascar.weeks w ON se.id = w.season_id AND w.deleted_at IS NULL
    WHERE s.deleted_at IS NULL
      AND (
          EXISTS (
              SELECT 1
              FROM nascar.practice_results pr
              JOIN nascar.practices p ON pr.practice_id = p.id AND p.deleted_at IS NULL
              WHERE pr.deleted_at IS NULL
                AND p.week_id = w.id
          )
          OR EXISTS (
              SELECT 1
              FROM nascar.qualifying_results qr
              JOIN nascar.qualifyings q ON qr.qualifying_id = q.id AND q.deleted_at IS NULL
              WHERE qr.deleted_at IS NULL
                AND q.week_id = w.id
          )
          OR EXISTS (
              SELECT 1
              FROM nascar.race_results rr
              JOIN nascar.races r ON rr.race_id = r.id AND r.deleted_at IS NULL
              WHERE rr.deleted_at IS NULL
                AND r.week_id = w.id
          )
      )
),
series_current_week AS (
    SELECT
        series_id,
        series_name,
        season_id,
        season_year,
        week_id,
        week_number,
        week_season_number
    FROM nascar.v_series_current_week
)
SELECT
    w.series_id,
    w.series_name,
    w.season_id,
    w.season_year,
    w.week_id,
    w.week_number,
    w.week_season_number
FROM weeks_with_activity w
JOIN series_current_week cw ON cw.series_id = w.series_id
WHERE (
    w.season_year < cw.season_year
    OR (
        w.season_year = cw.season_year
        AND w.week_number < cw.week_number
    )
    OR (
        w.season_year = cw.season_year
        AND w.week_number = cw.week_number
        AND COALESCE(w.week_season_number, 0) < COALESCE(cw.week_season_number, 0)
    )
)
;
