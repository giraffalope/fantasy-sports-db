DROP TRIGGER IF EXISTS `trg_drivers_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_drivers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`drivers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NEW.`deleted_at` WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NULL WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NULL WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
