DELIMITER //

CREATE OR REPLACE PROCEDURE `nascar`.`enriched_qualifying_results`(
    IN `q_qualifying_id` INT UNSIGNED
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
    FROM `nascar`.`qualifyings` q
    JOIN `nascar`.`weeks` w ON q.week_id = w.id AND w.deleted_at IS NULL
    JOIN `nascar`.`seasons` s ON w.season_id = s.id AND s.deleted_at IS NULL
    JOIN `nascar`.`series` sr ON s.series_id = sr.id AND sr.deleted_at IS NULL
    JOIN `nascar`.`qualifying_results` qr ON qr.qualifying_id = q.id AND qr.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars_drivers` cd ON cd.id = qr.car_driver_id AND cd.deleted_at IS NULL
    LEFT JOIN `nascar`.`drivers` d ON d.id = cd.driver_id AND d.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars` c ON c.id = cd.car_id AND c.deleted_at IS NULL
    LEFT JOIN `nascar`.`teams` t ON t.id = c.team_id AND t.deleted_at IS NULL
    LEFT JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
    WHERE q.id = q_qualifying_id
        AND q.deleted_at IS NULL
    ORDER BY qr.finish_position ASC;
END //

DELIMITER ;
