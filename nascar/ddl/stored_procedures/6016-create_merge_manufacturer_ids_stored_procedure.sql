-- merge_manufacturer_ids: stored procedure used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP PROCEDURE IF EXISTS `merge_manufacturer_ids`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `merge_manufacturer_ids`(
    IN `p_duplicate_manufacturer_id` BIGINT UNSIGNED,
    IN `p_canonical_manufacturer_id` BIGINT UNSIGNED
)
BEGIN
    DECLARE `v_duplicate_exists` TINYINT(1) DEFAULT 0;
    DECLARE `v_canonical_exists` TINYINT(1) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_duplicate_manufacturer_id = p_canonical_manufacturer_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate and canonical manufacturer ids must be different';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`manufacturers`
        WHERE `id` = p_duplicate_manufacturer_id
          AND `deleted_at` IS NULL
    ) INTO v_duplicate_exists;

    IF v_duplicate_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate manufacturer id does not exist or is already deleted';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`manufacturers`
        WHERE `id` = p_canonical_manufacturer_id
          AND `deleted_at` IS NULL
    ) INTO v_canonical_exists;

    IF v_canonical_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'canonical manufacturer id does not exist or is deleted';
    END IF;

    START TRANSACTION;

    CREATE TEMPORARY TABLE `tmp_manufacturer_merge_cars_map` (
        `old_car_id` BIGINT UNSIGNED NOT NULL PRIMARY KEY,
        `new_car_id` BIGINT UNSIGNED NULL
    ) ENGINE=MEMORY;

    INSERT INTO `tmp_manufacturer_merge_cars_map` (`old_car_id`, `new_car_id`)
    SELECT
        c_dup.`id` AS `old_car_id`,
        c_canon.`id` AS `new_car_id`
    FROM `nascar`.`cars` c_dup
    LEFT JOIN `nascar`.`cars` c_canon
      ON c_canon.`team_id` = c_dup.`team_id`
     AND c_canon.`manufacturer_id` = p_canonical_manufacturer_id
     AND c_canon.`number` = c_dup.`number`
    WHERE c_dup.`manufacturer_id` = p_duplicate_manufacturer_id;

    CREATE TEMPORARY TABLE `tmp_manufacturer_merge_cd_map` (
        `old_cd_id` BIGINT UNSIGNED NOT NULL PRIMARY KEY,
        `new_cd_id` BIGINT UNSIGNED NULL
    ) ENGINE=MEMORY;

    INSERT INTO `tmp_manufacturer_merge_cd_map` (`old_cd_id`, `new_cd_id`)
    SELECT
        cd_dup.`id` AS `old_cd_id`,
        cd_canon.`id` AS `new_cd_id`
    FROM `nascar`.`cars_drivers` cd_dup
    JOIN `tmp_manufacturer_merge_cars_map` cm
      ON cm.`old_car_id` = cd_dup.`car_id`
    LEFT JOIN `nascar`.`cars_drivers` cd_canon
      ON cd_canon.`car_id` = cm.`new_car_id`
     AND cd_canon.`driver_id` = cd_dup.`driver_id`
    WHERE cm.`new_car_id` IS NOT NULL;

    
    DELETE pr_dup
    FROM `nascar`.`practice_results` pr_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = pr_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`practice_results` pr_canon
      ON pr_canon.`practice_id` = pr_dup.`practice_id`
     AND pr_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`practice_results` pr
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = pr.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET pr.`car_driver_id` = m.`new_cd_id`;

    DELETE qr_dup
    FROM `nascar`.`qualifying_results` qr_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = qr_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`qualifying_results` qr_canon
      ON qr_canon.`qualifying_id` = qr_dup.`qualifying_id`
     AND qr_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`qualifying_results` qr
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = qr.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET qr.`car_driver_id` = m.`new_cd_id`;

    DELETE rr_dup
    FROM `nascar`.`race_results` rr_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = rr_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`race_results` rr_canon
      ON rr_canon.`race_id` = rr_dup.`race_id`
     AND rr_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`race_results` rr
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = rr.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET rr.`car_driver_id` = m.`new_cd_id`;

    DELETE ds_dup
    FROM `nascar`.`dfs_salaries` ds_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = ds_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`dfs_salaries` ds_canon
      ON ds_canon.`dfs_id` = ds_dup.`dfs_id`
     AND ds_canon.`race_id` = ds_dup.`race_id`
     AND ds_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`dfs_salaries` ds
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = ds.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET ds.`car_driver_id` = m.`new_cd_id`;

    DELETE ps_dup
    FROM `nascar`.`pitstops` ps_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = ps_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`pitstops` ps_canon
      ON ps_canon.`race_id` = ps_dup.`race_id`
     AND ps_canon.`car_driver_id` = m.`new_cd_id`
     AND ps_canon.`leader_lap` = ps_dup.`leader_lap`
     AND ps_canon.`driver_lap` = ps_dup.`driver_lap`;

    UPDATE `nascar`.`pitstops` ps
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = ps.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET ps.`car_driver_id` = m.`new_cd_id`;

    DELETE pn_dup
    FROM `nascar`.`penalties` pn_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = pn_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`penalties` pn_canon
      ON pn_canon.`race_id` = pn_dup.`race_id`
     AND pn_canon.`car_driver_id` = m.`new_cd_id`
     AND pn_canon.`lap` = pn_dup.`lap`;

    UPDATE `nascar`.`penalties` pn
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = pn.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET pn.`car_driver_id` = m.`new_cd_id`;

    DELETE wr_dup
    FROM `nascar`.`week_results` wr_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = wr_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`week_results` wr_canon
      ON wr_canon.`series_id` = wr_dup.`series_id`
     AND wr_canon.`season_id` = wr_dup.`season_id`
     AND wr_canon.`week_id` = wr_dup.`week_id`
     AND wr_canon.`race_id` = wr_dup.`race_id`
     AND wr_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`week_results` wr
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = wr.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET wr.`car_driver_id` = m.`new_cd_id`;

    DELETE hwtt_dup
    FROM `nascar`.`hist_weeks_track_types` hwtt_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = hwtt_dup.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    JOIN `nascar`.`hist_weeks_track_types` hwtt_canon
      ON hwtt_canon.`series_id` = hwtt_dup.`series_id`
     AND hwtt_canon.`season_id` = hwtt_dup.`season_id`
     AND hwtt_canon.`week_id` = hwtt_dup.`week_id`
     AND hwtt_canon.`race_id` = hwtt_dup.`race_id`
     AND hwtt_canon.`car_driver_id` = m.`new_cd_id`;

    UPDATE `nascar`.`hist_weeks_track_types` hwtt
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = hwtt.`car_driver_id`
     AND m.`new_cd_id` IS NOT NULL
    SET hwtt.`car_driver_id` = m.`new_cd_id`;

    
    UPDATE `nascar`.`week_results` wr
    JOIN `tmp_manufacturer_merge_cars_map` cm
      ON cm.`old_car_id` = wr.`car_id`
     AND cm.`new_car_id` IS NOT NULL
    SET wr.`car_id` = cm.`new_car_id`;

    UPDATE `nascar`.`hist_weeks_track_types` hwtt
    JOIN `tmp_manufacturer_merge_cars_map` cm
      ON cm.`old_car_id` = hwtt.`car_id`
     AND cm.`new_car_id` IS NOT NULL
    SET hwtt.`car_id` = cm.`new_car_id`;

    
    DELETE cd_dup
    FROM `nascar`.`cars_drivers` cd_dup
    JOIN `tmp_manufacturer_merge_cd_map` m
      ON m.`old_cd_id` = cd_dup.`id`
     AND m.`new_cd_id` IS NOT NULL;

    
    UPDATE `nascar`.`cars_drivers` cd
    JOIN `tmp_manufacturer_merge_cars_map` cm
      ON cm.`old_car_id` = cd.`car_id`
     AND cm.`new_car_id` IS NOT NULL
    SET cd.`car_id` = cm.`new_car_id`;

    
    DELETE c_dup
    FROM `nascar`.`cars` c_dup
    JOIN `tmp_manufacturer_merge_cars_map` cm
      ON cm.`old_car_id` = c_dup.`id`
     AND cm.`new_car_id` IS NOT NULL
    WHERE c_dup.`manufacturer_id` = p_duplicate_manufacturer_id;

    UPDATE `nascar`.`cars`
    SET `manufacturer_id` = p_canonical_manufacturer_id
    WHERE `manufacturer_id` = p_duplicate_manufacturer_id;

    
    UPDATE `nascar`.`week_results`
    SET `manufacturer_id` = p_canonical_manufacturer_id
    WHERE `manufacturer_id` = p_duplicate_manufacturer_id;

    UPDATE `nascar`.`hist_weeks_track_types`
    SET `manufacturer_id` = p_canonical_manufacturer_id
    WHERE `manufacturer_id` = p_duplicate_manufacturer_id;

    UPDATE `nascar`.`data_sources_manufacturers`
    SET `manufacturer_id` = p_canonical_manufacturer_id
    WHERE `manufacturer_id` = p_duplicate_manufacturer_id;

    UPDATE `nascar`.`manufacturers`
    SET
        `deleted_at` = IFNULL(`deleted_at`, CURRENT_TIMESTAMP),
        `updated_at` = CURRENT_TIMESTAMP
    WHERE `id` = p_duplicate_manufacturer_id;

    DROP TEMPORARY TABLE IF EXISTS `tmp_manufacturer_merge_cd_map`;
    DROP TEMPORARY TABLE IF EXISTS `tmp_manufacturer_merge_cars_map`;

    COMMIT;
END$$
DELIMITER ;
