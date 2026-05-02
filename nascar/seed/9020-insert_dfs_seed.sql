INSERT INTO `nascar`.`dfs` (`id`, `name`, `url`)
VALUES
    (1, 'DraftKings', 'https://frcs.pro/dfs/draftkings/cup/race-fantasy-points/'),
    (37, 'FanDuel', 'https://frcs.pro/dfs/fanduel/cup/race-fantasy-points/')
ON DUPLICATE KEY UPDATE
    `name` = VALUES(`name`),
    `url` = VALUES(`url`),
    `deleted_at` = NULL;
