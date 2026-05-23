-- FanDuel NASCAR Cup scoring rules (computed labels for ml_labels).
-- finish: 1=43, 2=40, else max(0, 41 - finish_position)
-- place_diff: 1.0 * (start - finish) when not stored on agg row
-- laps_completed: 0.1 per lap; laps_led: 0.1 per lap led

INSERT INTO `nascar`.`dfs_scoring_rules` (`id`, `dfs_id`, `name`, `version`, `rules`)
VALUES (
    1,
    37,
    'FanDuel Cup Race',
    1,
    JSON_OBJECT(
        'version', 1,
        'components', JSON_ARRAY(
            JSON_OBJECT(
                'name', 'finish',
                'source', 'r_finish_position',
                'type', 'finish_table',
                'table', JSON_OBJECT('1', 43, '2', 40),
                'formula', JSON_OBJECT('base', 41, 'subtract_position', true, 'min', 0)
            ),
            JSON_OBJECT(
                'name', 'place_diff',
                'source', 'r_place_diff',
                'fallback', JSON_OBJECT('from', JSON_ARRAY('r_start_position', 'r_finish_position'), 'op', 'subtract'),
                'type', 'linear',
                'multiplier', 1.0
            ),
            JSON_OBJECT(
                'name', 'laps',
                'source', 'r_total_laps_completed',
                'type', 'linear',
                'multiplier', 0.1
            ),
            JSON_OBJECT(
                'name', 'laps_led',
                'source', 'r_total_laps_led',
                'type', 'linear',
                'multiplier', 0.1
            )
        )
    )
)
ON DUPLICATE KEY UPDATE
    `rules` = VALUES(`rules`),
    `deleted_at` = NULL;
