INSERT INTO `nascar`.`track_types` (`id`, `name`, `description`)
VALUES
    (1, 'D-Shaped Oval', NULL),
    (2, 'Intermediate', NULL),
    (3, 'Restrictor Plate', NULL),
    (4, 'Road Course', NULL),
    (5, 'Flat', NULL),
    (6, 'Paper Clip Oval', NULL),
    (7, 'Short Track', NULL),
    (8, 'Stadium Oval', NULL),
    (9, 'Steep', NULL),
    (10, 'Large Oval', NULL),
    (11, 'Quad-oval', NULL),
    (12, 'Street Circuit', NULL),
    (13, 'Egg-shaped Oval', NULL),
    (14, 'Superspeedway', NULL),
    (15, 'Tri-oval', NULL),
    (16, 'Mile Oval', NULL),
    (17, 'Rounded-off Rectangle', NULL),
    (18, 'Rounded-off Triangle', NULL)
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `description` = VALUES(`description`),
    `deleted_at` = NULL;
