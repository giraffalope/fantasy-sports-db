-- DraftKings NASCAR Cup scoring rules (computed labels for ml_labels).
-- Finish: 1=45, 2=42, 3=41, 4=40, else max(0, 41 - finish_position) for finish >= 5
-- Place differential: 1.0 * positions gained (start - finish)
-- Fastest laps: 0.45 per r_total_fastest_laps; laps led: 0.25 per r_total_laps_led

INSERT INTO `nascar`.`dfs_scoring_rules` (`id`, `dfs_id`, `name`, `version`, `rules`)
VALUES (
    2,
    1,
    'DraftKings Cup Race',
    1,
    JSON_OBJECT(
        'version', 1,
        'components', JSON_ARRAY(
            JSON_OBJECT(
                'name', 'finish',
                'source', 'r_finish_position',
                'type', 'finish_table',
                'table', JSON_OBJECT('1', 45, '2', 42, '3', 41, '4', 40),
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
                'name', 'fastest_laps',
                'source', 'r_total_fastest_laps',
                'type', 'linear',
                'multiplier', 0.45
            ),
            JSON_OBJECT(
                'name', 'laps_led',
                'source', 'r_total_laps_led',
                'type', 'linear',
                'multiplier', 0.25
            )
        )
    )
)
ON DUPLICATE KEY UPDATE
    `rules` = VALUES(`rules`),
    `deleted_at` = NULL;
