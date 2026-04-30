DROP TRIGGER IF EXISTS `trg_tracks_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_tracks_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`tracks`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
