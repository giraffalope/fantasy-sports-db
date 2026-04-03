DELIMITER //

CREATE PROCEDURE `nascar`.`enriched_qualifying_results`(
    IN `q_series_name` VARCHAR(255),
    IN `q_year` INT UNSIGNED,
    IN `q_week_number` TINYINT UNSIGNED
)
BEGIN
    SELECT
        qr.`id` AS `qualifying_results_id`,
        qr.`qualifying_id`,
        qr.`car_driver_id`,
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
        qr.`finish_position`,
        qr.`best_speed`,
        qr.`best_time`,
        qr.`created_at`,
        qr.`updated_at`,
        qr.`deleted_at`
    FROM `nascar`.`series` s
    JOIN `nascar`.`seasons` se ON se.series_id = s.id
    JOIN `nascar`.`weeks` w ON w.season_id = se.id
    JOIN `nascar`.`qualifyings` q ON q.week_id = w.id
    JOIN `nascar`.`qualifying_results` qr ON qr.qualifying_id = q.id
    JOIN `nascar`.`cars_drivers` cd ON cd.id = qr.car_driver_id
    JOIN `nascar`.`drivers` d ON d.id = cd.driver_id
    JOIN `nascar`.`cars` c ON c.id = cd.car_id
    JOIN `nascar`.`teams` t ON t.id = c.team_id
    JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id
    WHERE s.name = q_series_name
        AND se.year = q_year
        AND w.number = q_week_number
        AND s.deleted_at IS NULL
        AND se.deleted_at IS NULL
        AND w.deleted_at IS NULL
        AND q.deleted_at IS NULL
        AND qr.deleted_at IS NULL
        AND cd.deleted_at IS NULL
        AND d.deleted_at IS NULL
        AND c.deleted_at IS NULL
        AND t.deleted_at IS NULL
        AND m.deleted_at IS NULL
    ORDER BY qr.finish_position ASC;
END //

DELIMITER ;
