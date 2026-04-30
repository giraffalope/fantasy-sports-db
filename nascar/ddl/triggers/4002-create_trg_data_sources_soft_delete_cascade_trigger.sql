DROP TRIGGER IF EXISTS `trg_data_sources_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_data_sources_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`data_sources`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`data_sources_drivers` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_teams` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_manufacturers` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_tracks` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`data_sources_drivers` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_teams` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_manufacturers` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_tracks` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
