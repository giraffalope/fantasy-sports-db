INSERT INTO `nascar`.`seasons` (`id`, `series_id`, `year`)
VALUES
    (1, 1, 2010),
    (2, 1, 2011),
    (3, 1, 2012),
    (4, 1, 2013),
    (5, 1, 2014),
    (6, 1, 2015),
    (7, 1, 2016),
    (8, 1, 2017),
    (9, 1, 2018),
    (10, 1, 2019),
    (11, 1, 2020),
    (12, 1, 2021),
    (13, 1, 2022),
    (14, 1, 2023),
    (15, 1, 2024),
    (16, 1, 2025),
    (17, 1, 2026)
ON DUPLICATE KEY UPDATE
    `series_id` = VALUES(`series_id`),
    `year` = VALUES(`year`),
    `deleted_at` = NULL;
