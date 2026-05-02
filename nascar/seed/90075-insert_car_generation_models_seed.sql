INSERT INTO `nascar`.`car_generation_models` (`id`, `name`)
VALUES
    (1, 'Camry'),
    (2, 'Impala'),
    (3, 'Charger'),
    (4, 'Fusion'),
    (5, 'SS'),
    (6, 'Camaro ZL1'),
    (7, 'Mustang'),
    (8, 'Camry TRD'),
    (9, 'Camry XSE'),
    (10, 'Mustang GT'),
    (11, 'Mustang Dark Horse')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `deleted_at` = NULL;
