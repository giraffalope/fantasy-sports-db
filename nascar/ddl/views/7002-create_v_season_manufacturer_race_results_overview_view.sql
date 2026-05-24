-- season_manufacturer_race_results_overview: view used by NASCAR analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP VIEW IF EXISTS `v_season_manufacturer_race_results_overview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_season_manufacturer_race_results_overview` AS
WITH base AS (
    SELECT
        awr.id AS awr_id,
        s.name AS series,
        se.year AS year,
        cg.name AS generation,
        m.name AS manufacturer,
        cgm.name AS model,
        awr.r_start_position AS r_start_position,
        awr.r_finish_position AS r_finish_position,
        awr.r_place_diff AS r_place_diff,
        awr.r_total_laps_led_pct AS r_total_laps_led_pct,
        awr.r_total_fastest_laps_pct AS r_total_fastest_laps_pct
    FROM nascar.agg_week_results awr
    JOIN nascar.series s ON s.id = awr.series_id
    JOIN nascar.seasons se ON se.id = awr.season_id
    JOIN nascar.car_generations cg ON cg.id = awr.car_generation_id
    JOIN nascar.manufacturers m ON m.id = awr.manufacturer_id
    JOIN nascar.car_generation_models cgm ON cgm.id = awr.car_generation_model_id
    WHERE awr.deleted_at IS NULL
      AND s.deleted_at IS NULL
      AND se.deleted_at IS NULL
      AND cg.deleted_at IS NULL
      AND m.deleted_at IS NULL
      AND cgm.deleted_at IS NULL
      AND awr.r_finish_position IS NOT NULL
),
avg_stats AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(AVG(r_start_position), 3) AS avg_start_position,
        ROUND(AVG(r_finish_position), 3) AS avg_finish_position,
        ROUND(AVG(r_place_diff), 3) AS avg_place_diff,
        ROUND(AVG(r_total_laps_led_pct), 3) AS avg_laps_led_pct,
        ROUND(AVG(r_total_fastest_laps_pct), 3) AS avg_fastest_laps_pct
    FROM base
    GROUP BY series, year, generation, manufacturer, model
),
median_start AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(
            AVG(
                CASE
                    WHEN rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2)) THEN r_start_position
                END
            ),
            3
        ) AS median_start_position
    FROM (
        SELECT
            series,
            year,
            generation,
            manufacturer,
            model,
            r_start_position,
            ROW_NUMBER() OVER (
                PARTITION BY series, year, generation, manufacturer, model
                ORDER BY r_start_position, awr_id
            ) AS rn,
            COUNT(*) OVER (
                PARTITION BY series, year, generation, manufacturer, model
            ) AS cnt
        FROM base
        WHERE r_start_position IS NOT NULL
    ) ranked
    GROUP BY series, year, generation, manufacturer, model
),
median_finish AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(
            AVG(
                CASE
                    WHEN rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2)) THEN r_finish_position
                END
            ),
            3
        ) AS median_finish_position
    FROM (
        SELECT
            series,
            year,
            generation,
            manufacturer,
            model,
            r_finish_position,
            ROW_NUMBER() OVER (
                PARTITION BY series, year, generation, manufacturer, model
                ORDER BY r_finish_position, awr_id
            ) AS rn,
            COUNT(*) OVER (
                PARTITION BY series, year, generation, manufacturer, model
            ) AS cnt
        FROM base
        WHERE r_finish_position IS NOT NULL
    ) ranked
    GROUP BY series, year, generation, manufacturer, model
),
median_place_diff AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(
            AVG(
                CASE
                    WHEN rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2)) THEN r_place_diff
                END
            ),
            3
        ) AS median_place_diff
    FROM (
        SELECT
            series,
            year,
            generation,
            manufacturer,
            model,
            r_place_diff,
            ROW_NUMBER() OVER (
                PARTITION BY series, year, generation, manufacturer, model
                ORDER BY r_place_diff, awr_id
            ) AS rn,
            COUNT(*) OVER (
                PARTITION BY series, year, generation, manufacturer, model
            ) AS cnt
        FROM base
        WHERE r_place_diff IS NOT NULL
    ) ranked
    GROUP BY series, year, generation, manufacturer, model
),
median_laps_led_pct AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(
            AVG(
                CASE
                    WHEN rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2)) THEN r_total_laps_led_pct
                END
            ),
            3
        ) AS median_laps_led_pct
    FROM (
        SELECT
            series,
            year,
            generation,
            manufacturer,
            model,
            r_total_laps_led_pct,
            ROW_NUMBER() OVER (
                PARTITION BY series, year, generation, manufacturer, model
                ORDER BY r_total_laps_led_pct, awr_id
            ) AS rn,
            COUNT(*) OVER (
                PARTITION BY series, year, generation, manufacturer, model
            ) AS cnt
        FROM base
        WHERE r_total_laps_led_pct IS NOT NULL
    ) ranked
    GROUP BY series, year, generation, manufacturer, model
),
median_fastest_laps_pct AS (
    SELECT
        series,
        year,
        generation,
        manufacturer,
        model,
        ROUND(
            AVG(
                CASE
                    WHEN rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2)) THEN r_total_fastest_laps_pct
                END
            ),
            3
        ) AS median_fastest_laps_pct
    FROM (
        SELECT
            series,
            year,
            generation,
            manufacturer,
            model,
            r_total_fastest_laps_pct,
            ROW_NUMBER() OVER (
                PARTITION BY series, year, generation, manufacturer, model
                ORDER BY r_total_fastest_laps_pct, awr_id
            ) AS rn,
            COUNT(*) OVER (
                PARTITION BY series, year, generation, manufacturer, model
            ) AS cnt
        FROM base
        WHERE r_total_fastest_laps_pct IS NOT NULL
    ) ranked
    GROUP BY series, year, generation, manufacturer, model
)
SELECT
    a.series,
    a.year,
    a.generation,
    a.manufacturer,
    a.model,
    a.avg_start_position,
    ms.median_start_position,
    a.avg_finish_position,
    mf.median_finish_position,
    a.avg_place_diff,
    mpd.median_place_diff,
    a.avg_laps_led_pct,
    mlp.median_laps_led_pct,
    a.avg_fastest_laps_pct,
    mfp.median_fastest_laps_pct
FROM avg_stats a
LEFT JOIN median_start ms
    ON ms.series = a.series
   AND ms.year = a.year
   AND ms.generation = a.generation
   AND ms.manufacturer = a.manufacturer
   AND ms.model = a.model
LEFT JOIN median_finish mf
    ON mf.series = a.series
   AND mf.year = a.year
   AND mf.generation = a.generation
   AND mf.manufacturer = a.manufacturer
   AND mf.model = a.model
LEFT JOIN median_place_diff mpd
    ON mpd.series = a.series
   AND mpd.year = a.year
   AND mpd.generation = a.generation
   AND mpd.manufacturer = a.manufacturer
   AND mpd.model = a.model
LEFT JOIN median_laps_led_pct mlp
    ON mlp.series = a.series
   AND mlp.year = a.year
   AND mlp.generation = a.generation
   AND mlp.manufacturer = a.manufacturer
   AND mlp.model = a.model
LEFT JOIN median_fastest_laps_pct mfp
    ON mfp.series = a.series
   AND mfp.year = a.year
   AND mfp.generation = a.generation
   AND mfp.manufacturer = a.manufacturer
   AND mfp.model = a.model
ORDER BY a.series, a.year, a.manufacturer, a.model;
