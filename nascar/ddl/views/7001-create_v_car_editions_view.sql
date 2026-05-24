-- car_editions: view used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP VIEW IF EXISTS `v_car_editions`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_car_editions` AS
SELECT
    s.name AS series,
    se.year AS year,
    cg.name AS generation,
    m.name AS manufacturer,
    cgm.name AS model
FROM nascar.car_generation_models_seasons cgms
JOIN nascar.car_generation_models cgm ON cgm.id = cgms.car_generation_model_id
JOIN nascar.car_generations_seasons cgs ON cgs.id = cgms.car_generations_seasons_id
JOIN nascar.car_generations cg ON cg.id = cgs.car_generation_id
JOIN nascar.seasons se ON se.id = cgs.season_id
JOIN nascar.series s ON s.id = se.series_id
JOIN nascar.manufacturers m ON m.id = cgms.manufacturer_id
WHERE cgms.deleted_at IS NULL
  AND cgm.deleted_at IS NULL
  AND cgs.deleted_at IS NULL
  AND cg.deleted_at IS NULL
  AND se.deleted_at IS NULL
  AND s.deleted_at IS NULL
  AND m.deleted_at IS NULL
ORDER BY series, year, generation, manufacturer, model;
