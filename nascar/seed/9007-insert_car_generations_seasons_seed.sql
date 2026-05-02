INSERT INTO `nascar`.`car_generations_seasons` (`id`, `car_generation_id`, `season_id`)
VALUES
    (1, 1, 1),
    (2, 1, 2),
    (3, 1, 3),
    (4, 2, 4),
    (5, 2, 5),
    (6, 2, 6),
    (7, 2, 7),
    (8, 2, 8),
    (9, 2, 9),
    (10, 2, 10),
    (11, 2, 11),
    (12, 2, 12),
    (13, 3, 13),
    (14, 3, 14),
    (15, 3, 15),
    (16, 3, 16),
    (17, 3, 17)
ON DUPLICATE KEY UPDATE
    `car_generation_id` = VALUES(`car_generation_id`),
    `season_id` = VALUES(`season_id`),
    `deleted_at` = NULL;
