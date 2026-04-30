DROP TRIGGER IF EXISTS `trg_track_types_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_track_types_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`track_types`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NEW.`deleted_at` WHERE `track_type_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NULL WHERE `track_type_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
