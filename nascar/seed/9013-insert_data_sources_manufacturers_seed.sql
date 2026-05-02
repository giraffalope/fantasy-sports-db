SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO `nascar`.`data_sources_manufacturers` (`id`, `data_source_id`, `manufacturer_id`, `name`)
VALUES
    (1, 3, 1, 'Toyota'),
    (2, 4, 1, 'Toyota'),
    (3, 3, 2, 'Chevrolet'),
    (4, 4, 2, 'Chevrolet'),
    (5, 3, 3, 'Dodge'),
    (6, 4, 3, 'Dodge'),
    (7, 3, 4, 'Ford'),
    (8, 4, 4, 'Ford')
ON DUPLICATE KEY UPDATE
    `data_source_id` = VALUES(`data_source_id`),
    `manufacturer_id` = VALUES(`manufacturer_id`),
    `name` = VALUES(`name`),
    `deleted_at` = NULL;

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
