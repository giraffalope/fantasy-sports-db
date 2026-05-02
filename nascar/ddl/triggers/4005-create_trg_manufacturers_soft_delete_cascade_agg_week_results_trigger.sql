DROP TRIGGER IF EXISTS `trg_manufacturers_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_manufacturers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`manufacturers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_manufacturers_results` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_manufacturers_results` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_manufacturers_results` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_prev_track_types_manufacturers_results` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
