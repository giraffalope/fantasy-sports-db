DROP TRIGGER IF EXISTS `trg_cars_drivers_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_cars_drivers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`cars_drivers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`agg_week_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
