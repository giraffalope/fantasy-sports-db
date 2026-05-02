INSERT INTO `nascar`.`car_generations` (`id`, `name`)
VALUES
    (1, 'Car of Tommorrow'),
    (2, 'Generation 6'),
    (3, 'Next Gen')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `deleted_at` = NULL;
