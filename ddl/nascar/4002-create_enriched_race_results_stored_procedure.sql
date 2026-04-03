DELIMITER //

CREATE PROCEDURE `nascar`.`enriched_race_results`(
    IN `r_series_name` VARCHAR(255),
    IN `r_year` INT UNSIGNED,
    IN `r_week_number` TINYINT UNSIGNED
)
BEGIN
    SELECT
        rr.`id` AS `race_results_id`,
        rr.`race_id`,
        rr.`car_driver_id`,
        d.id AS driver_id,
        d.first_name AS driver_first_name,
        d.last_name AS driver_last_name,
        d.suffix AS driver_suffix,
        c.id AS car_id,
        c.number AS car_number,
        m.id AS manufacturer_id,
        m.name AS manufacturer_name,
        t.id AS team_id,
        t.name AS team_name,
        rr.`start_position`,
        rr.`finish_position`,
        rr.`best_position`,
        rr.`worst_position`,
        rr.`average_position`,
        rr.`pass_diff`,
        rr.`green_flag_passes`,
        rr.`green_flag_times_passed`,
        rr.`quality_passes`,
        rr.`quality_passes_pct`,
        rr.`total_fastest_laps`,
        rr.`total_top_15_laps`,
        rr.`total_top_15_laps_pct`,
        rr.`total_laps_led`,
        rr.`total_laps_led_pct`,
        rr.`total_laps_completed`,
        rr.`driver_rating`,
        rr.`car_status`,
        rr.`created_at`,
        rr.`updated_at`,
        rr.`deleted_at`
    FROM `nascar`.`series` s
    JOIN `nascar`.`seasons` se ON se.series_id = s.id
    JOIN `nascar`.`weeks` w ON w.season_id = se.id
    JOIN `nascar`.`races` r ON r.week_id = w.id
    JOIN `nascar`.`race_results` rr ON rr.race_id = r.id
    JOIN `nascar`.`cars_drivers` cd ON cd.id = rr.car_driver_id
    JOIN `nascar`.`drivers` d ON d.id = cd.driver_id
    JOIN `nascar`.`cars` c ON c.id = cd.car_id
    JOIN `nascar`.`teams` t ON t.id = c.team_id
    JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id
    WHERE s.name = r_series_name
        AND se.year = r_year
        AND w.number = r_week_number
        AND s.deleted_at IS NULL
        AND se.deleted_at IS NULL
        AND w.deleted_at IS NULL
        AND r.deleted_at IS NULL
        AND rr.deleted_at IS NULL
        AND cd.deleted_at IS NULL
        AND d.deleted_at IS NULL
        AND c.deleted_at IS NULL
        AND t.deleted_at IS NULL
        AND m.deleted_at IS NULL
    ORDER BY rr.finish_position ASC, rr.start_position ASC;
END //

DELIMITER ;
