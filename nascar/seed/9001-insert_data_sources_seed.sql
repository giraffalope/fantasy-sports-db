-- Core reference rows for Airflow importers and `include.nascar.enums` / data source classes.
--
-- RacingReferenceSource.id = 'racing_reference' — without this row, SQL that joins
-- `data_sources.name = 'racing_reference'` inserts/updates nothing (e.g. qualifying_results).
-- FrcsSource.id = 'frcs' — same for `data_sources.name = 'frcs'`.
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
