-- One-time repair: lineup import wrote starting grid into finish_position.
-- Scope: current week only (v_series_current_week), lineup-only rows (no race stats).
-- Run preview queries first; wrap updates in a transaction.

-- Preview
SELECT 'race_results' AS tbl, rr.id, rr.car_driver_id,
       rr.start_position, rr.finish_position, rr.total_laps_completed
FROM nascar.race_results rr
JOIN nascar.races r ON r.id = rr.race_id AND r.deleted_at IS NULL
JOIN nascar.v_series_current_week cw ON cw.week_id = r.week_id
WHERE rr.deleted_at IS NULL
  AND rr.start_position IS NULL
  AND rr.finish_position IS NOT NULL;

SELECT 'agg_week_results' AS tbl, awr.id, awr.car_driver_id,
       awr.r_start_position, awr.r_finish_position, awr.r_total_laps_completed
FROM nascar.agg_week_results awr
JOIN nascar.v_series_current_week cw
  ON cw.week_id = awr.week_id AND cw.series_id = awr.series_id
WHERE awr.deleted_at IS NULL
  AND awr.r_start_position IS NULL
  AND awr.r_finish_position IS NOT NULL;

-- Repair
START TRANSACTION;

UPDATE nascar.race_results rr
JOIN nascar.races r ON r.id = rr.race_id AND r.deleted_at IS NULL
JOIN nascar.v_series_current_week cw ON cw.week_id = r.week_id
SET rr.start_position = rr.finish_position,
    rr.finish_position = NULL
WHERE rr.deleted_at IS NULL
  AND rr.start_position IS NULL
  AND rr.finish_position IS NOT NULL
  AND rr.total_laps_completed IS NULL;

UPDATE nascar.agg_week_results awr
JOIN nascar.v_series_current_week cw
  ON cw.week_id = awr.week_id AND cw.series_id = awr.series_id
SET awr.r_start_position = awr.r_finish_position,
    awr.r_finish_position = NULL,
    awr.r_place_diff = NULL
WHERE awr.deleted_at IS NULL
  AND awr.r_start_position IS NULL
  AND awr.r_finish_position IS NOT NULL
  AND awr.r_total_laps_completed IS NULL;

COMMIT;

-- After deploying proc 6019 with open-race support: rebuild base agg from race_results.
-- Required when agg_week_results has zero rows for the current week (UPDATE above is not enough).
-- CALL nascar.load_agg_week_results(1);

-- Then run nascar.cup.aggregate (wave-1 + agg_week_prev*) so prev-track tables populate.

-- Verify ML predict-window shape
SELECT awr.week_id, awr.car_driver_id,
       awr.r_start_position, awr.r_finish_position
FROM nascar.agg_week_results awr
JOIN nascar.v_series_current_week cw
  ON cw.week_id = awr.week_id AND cw.series_id = awr.series_id
WHERE awr.deleted_at IS NULL
  AND awr.r_start_position IS NOT NULL
  AND awr.r_finish_position IS NULL;
