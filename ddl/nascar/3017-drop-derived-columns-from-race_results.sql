ALTER TABLE `nascar`.`race_results`
    DROP COLUMN IF EXISTS `pass_diff`,
    DROP COLUMN IF EXISTS `quality_passes_pct`,
    DROP COLUMN IF EXISTS `total_top_15_laps_pct`,
    DROP COLUMN IF EXISTS `total_laps_led_pct`;
