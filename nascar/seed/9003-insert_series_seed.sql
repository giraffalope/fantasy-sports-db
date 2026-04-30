INSERT INTO `nascar`.`series` (`id`, `name`, `description`)
VALUES (1, 'Cup', 'NASCAR Cup Series')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `description` = VALUES(`description`),
    `deleted_at` = NULL;
