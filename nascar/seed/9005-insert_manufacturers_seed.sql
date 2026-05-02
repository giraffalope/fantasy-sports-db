INSERT INTO `nascar`.`manufacturers` (`id`, `series_id`, `name`, `image`)
VALUES
    (1, 1, 'Toyota', NULL),
    (2, 1, 'Chevrolet', NULL),
    (3, 1, 'Dodge', NULL),
    (4, 1, 'Ford', NULL)
ON DUPLICATE KEY UPDATE
    `series_id` = VALUES(`series_id`),
    `name` = VALUES(`name`),
    `image` = VALUES(`image`),
    `deleted_at` = NULL;
