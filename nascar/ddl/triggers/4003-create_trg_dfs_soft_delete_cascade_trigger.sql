DROP TRIGGER IF EXISTS `trg_dfs_soft_delete_cascade`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` TRIGGER `nascar`.`trg_dfs_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`dfs`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NEW.`deleted_at` WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`dfs_scoring_rules` SET `deleted_at` = NEW.`deleted_at` WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NULL WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`dfs_scoring_rules` SET `deleted_at` = NULL WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END$$
DELIMITER ;
