DROP TRIGGER IF EXISTS `trg_weeks_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_weeks_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`weeks`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`races` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`practices` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`qualifyings` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_teams_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_teams_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cars_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_cars_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generations_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_teams_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cars_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cars_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_drivers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generations_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generation_models_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`races` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`practices` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`qualifyings` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_manufacturers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_teams_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_manufacturers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_teams_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cars_drivers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_cars_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_drivers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generations_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_car_generation_models_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_manufacturers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_teams_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cars_drivers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_cars_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_drivers_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generations_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_car_generation_models_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
