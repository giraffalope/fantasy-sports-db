DELIMITER //

CREATE PROCEDURE `nascar`.`enriched_practice_results`(
    IN `p_series_name` VARCHAR(255),
    IN `p_year` INT UNSIGNED,
    IN `p_week_number` TINYINT UNSIGNED,
    IN `p_practice_number` INT UNSIGNED
)
BEGIN
    SELECT
        pr.`id` AS `practice_results_id`,
        pr.`practice_id`,
        pr.`car_driver_id`,
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
        pr.`finish_position`,
        pr.`best_speed`,
        pr.`best_time`,
        pr.`total_laps`,
        pr.`5_lap_average_time`,
        pr.`10_lap_average_time`,
        pr.`20_lap_average_time`,
        pr.`25_lap_average_time`,
        pr.`30_lap_average_time`,
        pr.`10_lap_average_speed`,
        pr.`10_lap_start`,
        pr.`10_lap_end`,
        pr.`created_at`,
        pr.`updated_at`,
        pr.`deleted_at`
    FROM `nascar`.`series` s
    JOIN `nascar`.`seasons` se ON se.series_id = s.id
    JOIN `nascar`.`weeks` w ON w.season_id = se.id
    JOIN `nascar`.`practices` p ON p.week_id = w.id
    JOIN `nascar`.`practice_results` pr ON pr.practice_id = p.id
    JOIN `nascar`.`cars_drivers` cd ON cd.id = pr.car_driver_id
    JOIN `nascar`.`drivers` d ON d.id = cd.driver_id
    JOIN `nascar`.`cars` c ON c.id = cd.car_id
    JOIN `nascar`.`teams` t ON t.id = c.team_id
    JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id
    WHERE s.name = p_series_name
        AND se.year = p_year
        AND w.number = p_week_number
        AND p.number = p_practice_number
        AND s.deleted_at IS NULL
        AND se.deleted_at IS NULL
        AND w.deleted_at IS NULL
        AND p.deleted_at IS NULL
        AND pr.deleted_at IS NULL
        AND cd.deleted_at IS NULL
        AND d.deleted_at IS NULL
        AND c.deleted_at IS NULL
        AND t.deleted_at IS NULL
        AND m.deleted_at IS NULL
    ORDER BY pr.finish_position ASC;
END //

DELIMITER ;
