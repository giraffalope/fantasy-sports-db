-- merge_track_ids: consolidate duplicate nascar.tracks rows into a canonical track_id.
-- Re-points track_id / week_id FKs, resolves unique-key conflicts (delete-then-update), soft-deletes duplicate.

DROP PROCEDURE IF EXISTS `merge_track_ids`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `merge_track_ids`(
    IN `p_duplicate_track_id` BIGINT UNSIGNED,
    IN `p_canonical_track_id` BIGINT UNSIGNED
)
BEGIN
    DECLARE `v_duplicate_exists` TINYINT(1) DEFAULT 0;
    DECLARE `v_canonical_exists` TINYINT(1) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_duplicate_track_id = p_canonical_track_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate and canonical track ids must be different';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`tracks`
        WHERE `id` = p_duplicate_track_id
          AND `deleted_at` IS NULL
    ) INTO v_duplicate_exists;

    IF v_duplicate_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'duplicate track id does not exist or is already deleted';
    END IF;

    SELECT EXISTS(
        SELECT 1
        FROM `nascar`.`tracks`
        WHERE `id` = p_canonical_track_id
          AND `deleted_at` IS NULL
    ) INTO v_canonical_exists;

    IF v_canonical_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'canonical track id does not exist or is deleted';
    END IF;

    START TRANSACTION;

    CREATE TEMPORARY TABLE `tmp_track_merge_week_map` (
        `old_week_id` BIGINT UNSIGNED NOT NULL PRIMARY KEY,
        `new_week_id` BIGINT UNSIGNED NOT NULL
    ) ENGINE=MEMORY;

    INSERT INTO `tmp_track_merge_week_map` (`old_week_id`, `new_week_id`)
    SELECT
        w_dup.`id` AS `old_week_id`,
        w_canon.`id` AS `new_week_id`
    FROM `nascar`.`weeks` w_dup
    INNER JOIN `nascar`.`weeks` w_canon
        ON w_canon.`season_id` = w_dup.`season_id`
       AND w_canon.`number` = w_dup.`number`
       AND w_canon.`season_number` = w_dup.`season_number`
       AND w_canon.`track_id` = p_canonical_track_id
       AND w_canon.`deleted_at` IS NULL
    WHERE w_dup.`track_id` = p_duplicate_track_id
      AND w_dup.`deleted_at` IS NULL;

    -- ml_training_snapshots: drop dup rows that would collide after week repoint
    DELETE s_dup
    FROM `nascar`.`ml_training_snapshots` s_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = s_dup.`week_id`
    INNER JOIN `nascar`.`ml_training_snapshots` s_canon
        ON s_canon.`series_id` = s_dup.`series_id`
       AND s_canon.`week_id` = m.`new_week_id`
       AND s_canon.`grain` = s_dup.`grain`
       AND s_canon.`kind` = s_dup.`kind`
       AND s_canon.`dfs_scoring_rules_id` = s_dup.`dfs_scoring_rules_id`
       AND s_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`ml_training_snapshots` s
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = s.`week_id`
    SET s.`week_id` = m.`new_week_id`;

    -- agg_week_results (UK excludes track_id)
    DELETE wr_dup
    FROM `nascar`.`agg_week_results` wr_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = wr_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_results` wr_canon
        ON wr_canon.`series_id` = wr_dup.`series_id`
       AND wr_canon.`season_id` = wr_dup.`season_id`
       AND wr_canon.`week_id` = m.`new_week_id`
       AND wr_canon.`race_id` = wr_dup.`race_id`
       AND wr_canon.`car_driver_id` = wr_dup.`car_driver_id`
       AND wr_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_results` wr
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = wr.`week_id`
    SET wr.`week_id` = m.`new_week_id`;

    -- hist_weeks_track_types (UK excludes track_id)
    DELETE hwtt_dup
    FROM `nascar`.`hist_weeks_track_types` hwtt_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = hwtt_dup.`week_id`
    INNER JOIN `nascar`.`hist_weeks_track_types` hwtt_canon
        ON hwtt_canon.`series_id` = hwtt_dup.`series_id`
       AND hwtt_canon.`season_id` = hwtt_dup.`season_id`
       AND hwtt_canon.`week_id` = m.`new_week_id`
       AND hwtt_canon.`race_id` = hwtt_dup.`race_id`
       AND hwtt_canon.`car_driver_id` = hwtt_dup.`car_driver_id`
       AND hwtt_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`hist_weeks_track_types` hwtt
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = hwtt.`week_id`
    SET hwtt.`week_id` = m.`new_week_id`;

    -- agg_week_manufacturers_results (UK includes track_id)
    DELETE awmfr_dup
    FROM `nascar`.`agg_week_manufacturers_results` awmfr_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = awmfr_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_manufacturers_results` awmfr_canon
        ON awmfr_canon.`series_id` = awmfr_dup.`series_id`
       AND awmfr_canon.`season_id` = awmfr_dup.`season_id`
       AND awmfr_canon.`week_id` = m.`new_week_id`
       AND awmfr_canon.`track_id` = awmfr_dup.`track_id`
       AND awmfr_canon.`race_id` = awmfr_dup.`race_id`
       AND awmfr_canon.`manufacturer_id` = awmfr_dup.`manufacturer_id`
       AND awmfr_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_manufacturers_results` awmfr
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = awmfr.`week_id`
    SET awmfr.`week_id` = m.`new_week_id`;

    -- agg_week_teams_results
    DELETE awtr_dup
    FROM `nascar`.`agg_week_teams_results` awtr_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = awtr_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_teams_results` awtr_canon
        ON awtr_canon.`series_id` = awtr_dup.`series_id`
       AND awtr_canon.`season_id` = awtr_dup.`season_id`
       AND awtr_canon.`week_id` = m.`new_week_id`
       AND awtr_canon.`track_id` = awtr_dup.`track_id`
       AND awtr_canon.`race_id` = awtr_dup.`race_id`
       AND awtr_canon.`team_id` = awtr_dup.`team_id`
       AND awtr_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_teams_results` awtr
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = awtr.`week_id`
    SET awtr.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_manufacturers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`manufacturer_id` = t_dup.`manufacturer_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_teams_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`team_id` = t_dup.`team_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cars_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_driver_id` = t_dup.`car_driver_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cars_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_id` = t_dup.`car_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`driver_id` = t_dup.`driver_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_car_generations_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_car_generations_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_car_generations_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_car_generations_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_car_generation_models_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_car_generation_models_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_car_generation_models_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cg_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_cars_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cg_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cg_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cgm_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cg_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_cars_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cg_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cg_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cgm_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_cars_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cgm_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cg_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cg_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cg_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cgm_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_drivers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cgm_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cg_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_manufacturers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cg_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cg_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cgm_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_manufacturers_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cgm_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cg_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_teams_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cg_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cg_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_cgm_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_teams_results` t_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t_dup.`week_id`
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = m.`new_week_id`
       AND t_canon.`track_id` = t_dup.`track_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`deleted_at` IS NULL;

    UPDATE `nascar`.`agg_week_prev_track_cgm_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- agg_week_prev_track_types_* (week_id only; keyed by track_type_id)
    UPDATE `nascar`.`agg_week_prev_track_types_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_car_generations_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_car_generation_models_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cg_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cg_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cg_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cgm_drivers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cg_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cgm_manufacturers_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cg_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`agg_week_prev_track_types_cgm_teams_results` t
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = t.`week_id`
    SET t.`week_id` = m.`new_week_id`;

    -- Session tables (no UK collision risk on week_id alone)
    UPDATE `nascar`.`races` r
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = r.`week_id`
    SET r.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`practices` p
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = p.`week_id`
    SET p.`week_id` = m.`new_week_id`;

    UPDATE `nascar`.`qualifyings` q
    INNER JOIN `tmp_track_merge_week_map` m ON m.`old_week_id` = q.`week_id`
    SET q.`week_id` = m.`new_week_id`;

    DELETE w_dup
    FROM `nascar`.`weeks` w_dup
    INNER JOIN `tmp_track_merge_week_map` m
        ON m.`old_week_id` = w_dup.`id`;

    UPDATE `nascar`.`weeks`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- tracks_track_types
    DELETE ttt_dup
    FROM `nascar`.`tracks_track_types` ttt_dup
    INNER JOIN `nascar`.`tracks_track_types` ttt_canon
        ON ttt_canon.`track_id` = p_canonical_track_id
       AND ttt_canon.`track_type_id` = ttt_dup.`track_type_id`
       AND ttt_canon.`deleted_at` IS NULL
    WHERE ttt_dup.`track_id` = p_duplicate_track_id
      AND ttt_dup.`deleted_at` IS NULL;

    UPDATE `nascar`.`tracks_track_types`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- track_id merge: agg_week_results (UK without track_id)
    DELETE wr_dup
    FROM `nascar`.`agg_week_results` wr_dup
    INNER JOIN `nascar`.`agg_week_results` wr_canon
        ON wr_canon.`series_id` = wr_dup.`series_id`
       AND wr_canon.`season_id` = wr_dup.`season_id`
       AND wr_canon.`week_id` = wr_dup.`week_id`
       AND wr_canon.`race_id` = wr_dup.`race_id`
       AND wr_canon.`car_driver_id` = wr_dup.`car_driver_id`
       AND wr_canon.`track_id` = p_canonical_track_id
       AND wr_canon.`deleted_at` IS NULL
    WHERE wr_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- hist_weeks_track_types
    DELETE hwtt_dup
    FROM `nascar`.`hist_weeks_track_types` hwtt_dup
    INNER JOIN `nascar`.`hist_weeks_track_types` hwtt_canon
        ON hwtt_canon.`series_id` = hwtt_dup.`series_id`
       AND hwtt_canon.`season_id` = hwtt_dup.`season_id`
       AND hwtt_canon.`week_id` = hwtt_dup.`week_id`
       AND hwtt_canon.`race_id` = hwtt_dup.`race_id`
       AND hwtt_canon.`car_driver_id` = hwtt_dup.`car_driver_id`
       AND hwtt_canon.`track_id` = p_canonical_track_id
       AND hwtt_canon.`deleted_at` IS NULL
    WHERE hwtt_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`hist_weeks_track_types`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_manufacturers_results` t_dup
    INNER JOIN `nascar`.`agg_week_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`race_id` = t_dup.`race_id`
       AND t_canon.`manufacturer_id` = t_dup.`manufacturer_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_manufacturers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_teams_results` t_dup
    INNER JOIN `nascar`.`agg_week_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`race_id` = t_dup.`race_id`
       AND t_canon.`team_id` = t_dup.`team_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_teams_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_manufacturers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`manufacturer_id` = t_dup.`manufacturer_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_manufacturers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_teams_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`team_id` = t_dup.`team_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_teams_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cars_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_driver_id` = t_dup.`car_driver_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cars_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cars_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_id` = t_dup.`car_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cars_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`driver_id` = t_dup.`driver_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_car_generations_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_car_generations_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_car_generations_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_car_generations_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_car_generation_models_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_car_generation_models_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_car_generation_models_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cg_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_cars_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cg_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cg_cars_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cgm_cars_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cgm_cars_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cg_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_cars_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cg_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cg_cars_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cgm_cars_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_cars_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_cars_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cgm_cars_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cg_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cg_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cg_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cgm_drivers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_drivers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_drivers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cgm_drivers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cg_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_manufacturers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cg_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cg_manufacturers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cgm_manufacturers_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_manufacturers_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_manufacturers_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cgm_manufacturers_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cg_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cg_teams_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cg_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cg_teams_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- agg_week_prev_track_cgm_teams_results
    DELETE t_dup
    FROM `nascar`.`agg_week_prev_track_cgm_teams_results` t_dup
    INNER JOIN `nascar`.`agg_week_prev_track_cgm_teams_results` t_canon
        ON t_canon.`series_id` = t_dup.`series_id`
       AND t_canon.`season_id` = t_dup.`season_id`
       AND t_canon.`week_id` = t_dup.`week_id`
       AND t_canon.`car_generation_id` = t_dup.`car_generation_id`
       AND t_canon.`car_generation_model_id` = t_dup.`car_generation_model_id`
       AND t_canon.`track_id` = p_canonical_track_id
       AND t_canon.`deleted_at` IS NULL
    WHERE t_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`agg_week_prev_track_cgm_teams_results`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    -- ml_training_snapshots (track_id merge)
    DELETE s_dup
    FROM `nascar`.`ml_training_snapshots` s_dup
    INNER JOIN `nascar`.`ml_training_snapshots` s_canon
        ON s_canon.`series_id` = s_dup.`series_id`
       AND s_canon.`week_id` = s_dup.`week_id`
       AND s_canon.`grain` = s_dup.`grain`
       AND s_canon.`kind` = s_dup.`kind`
       AND s_canon.`dfs_scoring_rules_id` = s_dup.`dfs_scoring_rules_id`
       AND s_canon.`track_id` = p_canonical_track_id
       AND s_canon.`deleted_at` IS NULL
    WHERE s_dup.`track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`ml_training_snapshots`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`ml_models`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id
      AND `model_scope` = 'track';

    UPDATE `nascar`.`data_sources_tracks`
    SET `track_id` = p_canonical_track_id
    WHERE `track_id` = p_duplicate_track_id;

    UPDATE `nascar`.`tracks`
    SET
        `deleted_at` = IFNULL(`deleted_at`, CURRENT_TIMESTAMP),
        `updated_at` = CURRENT_TIMESTAMP
    WHERE `id` = p_duplicate_track_id;

    DROP TEMPORARY TABLE IF EXISTS `tmp_track_merge_week_map`;

    COMMIT;
END$$
DELIMITER ;
