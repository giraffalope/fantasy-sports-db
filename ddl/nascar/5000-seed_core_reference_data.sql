-- Core reference rows for Airflow importers and `include.nascar.enums` / data source classes.
--
-- RacingReferenceSource.id = 'racing_reference' — without this row, SQL that joins
-- `data_sources.name = 'racing_reference'` inserts/updates nothing (e.g. qualifying_results).
-- FrcsSource.id = 'frcs' — same for `data_sources.name = 'frcs'`.
-- NascarSeries.CUP uses series_id = 1 and db_name 'Cup' — must match `nascar.series.id` / `name`.

INSERT INTO `nascar`.`data_sources` (`name`, `url`)
VALUES ('frcs', 'https://frcs.pro')
ON DUPLICATE KEY UPDATE
    `deleted_at` = NULL,
    `url` = VALUES(`url`);

INSERT INTO `nascar`.`data_sources` (`name`, `url`)
VALUES ('racing_reference', 'https://www.racing-reference.info')
ON DUPLICATE KEY UPDATE
    `deleted_at` = NULL,
    `url` = VALUES(`url`);

-- Fixed primary key 1: see `include.nascar.enums.NascarSeries.CUP`.
-- If another row already uses `name = 'Cup'` with a different `id`, resolve duplicates manually
-- so this row can own `id = 1` (unique on `name` may otherwise block the insert).
INSERT INTO `nascar`.`series` (`id`, `name`, `description`)
VALUES (1, 'Cup', 'NASCAR Cup Series')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `description` = VALUES(`description`),
    `deleted_at` = NULL;
