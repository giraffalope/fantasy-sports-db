-- merge_cars_drivers_ids: stored procedure used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `merge_cars_drivers_ids`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `merge_cars_drivers_ids`(
    IN `p_duplicate_car_driver_id` BIGINT UNSIGNED,
    IN `p_canonical_car_driver_id` BIGINT UNSIGNED
)
BEGIN
    DECLARE `v_duplicate_exists` TINYINT(1) DEFAULT 0;
    DECLARE `v_canonical_exists` TINYINT(1) DEFAULT 0;
    DECLARE `v_canonical_car_id` BIGINT UNSIGNED;
    DECLARE `v_canonical_driver_id` BIGINT UNSIGNED;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_duplicate_car_driver_id = p_canonical_car_driver_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate and canonical car_driver ids must be different';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`cars_drivers`
        WHERE `id` = p_duplicate_car_driver_id
          AND `deleted_at` IS NULL
    ) INTO v_duplicate_exists;

    IF v_duplicate_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate car_driver id does not exist or is already deleted';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`cars_drivers`
        WHERE `id` = p_canonical_car_driver_id
          AND `deleted_at` IS NULL
    ) INTO v_canonical_exists;

    IF v_canonical_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'canonical car_driver id does not exist or is deleted';
    END IF;

    SELECT `car_id`, `driver_id`
    INTO v_canonical_car_id, v_canonical_driver_id
    FROM `nascar`.`cars_drivers`
    WHERE `id` = p_canonical_car_driver_id;

    START TRANSACTION;

    DELETE pr_dup
    FROM `nascar`.`practice_results` pr_dup
    JOIN `nascar`.`practice_results` pr_canon
      ON pr_canon.`practice_id` = pr_dup.`practice_id`
     AND pr_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE pr_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`practice_results`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE qr_dup
    FROM `nascar`.`qualifying_results` qr_dup
    JOIN `nascar`.`qualifying_results` qr_canon
      ON qr_canon.`qualifying_id` = qr_dup.`qualifying_id`
     AND qr_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE qr_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`qualifying_results`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE rr_dup
    FROM `nascar`.`race_results` rr_dup
    JOIN `nascar`.`race_results` rr_canon
      ON rr_canon.`race_id` = rr_dup.`race_id`
     AND rr_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE rr_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`race_results`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE ds_dup
    FROM `nascar`.`dfs_salaries` ds_dup
    JOIN `nascar`.`dfs_salaries` ds_canon
      ON ds_canon.`dfs_id` = ds_dup.`dfs_id`
     AND ds_canon.`race_id` = ds_dup.`race_id`
     AND ds_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE ds_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`dfs_salaries`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE ps_dup
    FROM `nascar`.`pitstops` ps_dup
    JOIN `nascar`.`pitstops` ps_canon
      ON ps_canon.`race_id` = ps_dup.`race_id`
     AND ps_canon.`car_driver_id` = p_canonical_car_driver_id
     AND ps_canon.`leader_lap` = ps_dup.`leader_lap`
     AND ps_canon.`driver_lap` = ps_dup.`driver_lap`
    WHERE ps_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`pitstops`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE pn_dup
    FROM `nascar`.`penalties` pn_dup
    JOIN `nascar`.`penalties` pn_canon
      ON pn_canon.`race_id` = pn_dup.`race_id`
     AND pn_canon.`car_driver_id` = p_canonical_car_driver_id
     AND pn_canon.`lap` = pn_dup.`lap`
    WHERE pn_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`penalties`
    SET `car_driver_id` = p_canonical_car_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE wr_dup
    FROM `nascar`.`agg_week_results` wr_dup
    JOIN `nascar`.`agg_week_results` wr_canon
      ON wr_canon.`series_id` = wr_dup.`series_id`
     AND wr_canon.`season_id` = wr_dup.`season_id`
     AND wr_canon.`week_id` = wr_dup.`week_id`
     AND wr_canon.`race_id` = wr_dup.`race_id`
     AND wr_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE wr_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`agg_week_results`
    SET
        `car_driver_id` = p_canonical_car_driver_id,
        `car_id` = v_canonical_car_id,
        `driver_id` = v_canonical_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    DELETE hwtt_dup
    FROM `nascar`.`hist_weeks_track_types` hwtt_dup
    JOIN `nascar`.`hist_weeks_track_types` hwtt_canon
      ON hwtt_canon.`series_id` = hwtt_dup.`series_id`
     AND hwtt_canon.`season_id` = hwtt_dup.`season_id`
     AND hwtt_canon.`week_id` = hwtt_dup.`week_id`
     AND hwtt_canon.`race_id` = hwtt_dup.`race_id`
     AND hwtt_canon.`car_driver_id` = p_canonical_car_driver_id
    WHERE hwtt_dup.`car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`hist_weeks_track_types`
    SET
        `car_driver_id` = p_canonical_car_driver_id,
        `car_id` = v_canonical_car_id,
        `driver_id` = v_canonical_driver_id
    WHERE `car_driver_id` = p_duplicate_car_driver_id;

    UPDATE `nascar`.`cars_drivers`
    SET
        `deleted_at` = IFNULL(`deleted_at`, CURRENT_TIMESTAMP),
        `updated_at` = CURRENT_TIMESTAMP
    WHERE `id` = p_duplicate_car_driver_id;

    COMMIT;
END$$
DELIMITER ;
