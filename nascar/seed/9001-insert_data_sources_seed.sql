INSERT INTO `nascar`.`data_sources` (`id`, `name`, `url`)
VALUES
    (3, 'frcs', 'https://frcs.pro'),
    (4, 'racing_reference', 'https://www.racing-reference.info')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `url` = VALUES(`url`),
    `deleted_at` = NULL;
