DELIMITER //

CREATE OR REPLACE PROCEDURE `nascar`.`enriched_practice_results`(
    IN `p_practice_id` INT UNSIGNED
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
    FROM `nascar`.`weeks` w
    JOIN `nascar`.`seasons` s ON w.season_id = s.id AND s.deleted_at IS NULL
    JOIN `nascar`.`series` sr ON s.series_id = sr.id AND sr.deleted_at IS NULL
    JOIN `nascar`.`practices` p ON p.week_id = w.id AND p.deleted_at IS NULL
    JOIN `nascar`.`practice_results` pr ON pr.practice_id = p.id AND pr.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars_drivers` cd ON cd.id = pr.car_driver_id AND cd.deleted_at IS NULL
    LEFT JOIN `nascar`.`drivers` d ON d.id = cd.driver_id AND d.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars` c ON c.id = cd.car_id AND c.deleted_at IS NULL
    LEFT JOIN `nascar`.`teams` t ON t.id = c.team_id AND t.deleted_at IS NULL
    LEFT JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
    WHERE p.id = p_practice_id
        AND w.deleted_at IS NULL
    ORDER BY pr.finish_position ASC;
END //

DELIMITER ;