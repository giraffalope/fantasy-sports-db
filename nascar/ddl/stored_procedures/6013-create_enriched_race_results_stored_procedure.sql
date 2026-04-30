-- enriched_race_results: stored procedure used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `enriched_race_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `enriched_race_results`(
    IN `r_race_id` INT UNSIGNED
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
        (
            CAST(rr.`green_flag_passes` AS SIGNED) -
            CAST(rr.`green_flag_times_passed` AS SIGNED)
        ) AS `pass_diff`,
        rr.`green_flag_passes`,
        rr.`green_flag_times_passed`,
        rr.`quality_passes`,
        ROUND(rr.`quality_passes` / NULLIF(rr.`green_flag_passes`, 0), 3) AS `quality_passes_pct`,
        rr.`total_fastest_laps`,
        rr.`total_top_15_laps`,
        ROUND(rr.`total_top_15_laps` / NULLIF(rr.`total_laps_completed`, 0), 3) AS `total_top_15_laps_pct`,
        rr.`total_laps_led`,
        ROUND(rr.`total_laps_led` / NULLIF(rr.`total_laps_completed`, 0), 3) AS `total_laps_led_pct`,
        rr.`total_laps_completed`,
        rr.`driver_rating`,
        rr.`car_status`,
        rr.`created_at`,
        rr.`updated_at`,
        rr.`deleted_at`
    FROM `nascar`.`races` r
    JOIN `nascar`.`weeks` w ON r.week_id = w.id AND w.deleted_at IS NULL
    JOIN `nascar`.`seasons` s ON w.season_id = s.id AND s.deleted_at IS NULL
    JOIN `nascar`.`series` sr ON s.series_id = sr.id AND sr.deleted_at IS NULL
    JOIN `nascar`.`race_results` rr ON rr.race_id = r.id AND rr.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars_drivers` cd ON cd.id = rr.car_driver_id AND cd.deleted_at IS NULL
    LEFT JOIN `nascar`.`drivers` d ON d.id = cd.driver_id AND d.deleted_at IS NULL
    LEFT JOIN `nascar`.`cars` c ON c.id = cd.car_id AND c.deleted_at IS NULL
    LEFT JOIN `nascar`.`teams` t ON t.id = c.team_id AND t.deleted_at IS NULL
    LEFT JOIN `nascar`.`manufacturers` m ON m.id = c.manufacturer_id AND m.deleted_at IS NULL
    WHERE r.id = r_race_id
        AND r.deleted_at IS NULL
    ORDER BY rr.finish_position ASC, rr.start_position ASC;
END$$
DELIMITER ;
