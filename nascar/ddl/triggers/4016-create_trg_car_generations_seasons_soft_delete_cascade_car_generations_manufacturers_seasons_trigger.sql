DROP TRIGGER IF EXISTS `trg_car_generations_seasons_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_car_generations_seasons_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`car_generations_seasons`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NEW.`deleted_at` WHERE `car_generations_seasons_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`car_generation_models_seasons` SET `deleted_at` = NULL WHERE `car_generations_seasons_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
