DROP TRIGGER IF EXISTS `trg_car_generation_models_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_car_generation_models_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`car_generation_models`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generation_models_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_cars_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_teams_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_teams_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generation_models_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_cars_drivers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_cars_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_drivers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_manufacturers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cgm_teams_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_drivers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_cars_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_drivers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_manufacturers_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cgm_teams_results` SET `deleted_at` = NULL WHERE `car_generation_model_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
