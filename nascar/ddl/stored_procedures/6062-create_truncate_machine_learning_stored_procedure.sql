-- truncate_machine_learning: TRUNCATE all nascar.ml_* base tables (ML pipeline outputs only).

DROP PROCEDURE IF EXISTS `truncate_machine_learning`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `truncate_machine_learning`()
    COMMENT 'Truncate all nascar.ml_* tables (ML pipeline outputs only).'
BEGIN
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_table VARCHAR(64);
    DECLARE v_old_fk_checks INT DEFAULT @@FOREIGN_KEY_CHECKS;
    DECLARE cur_tables CURSOR FOR
        SELECT TABLE_NAME
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = 'nascar'
          AND TABLE_TYPE = 'BASE TABLE'
          AND TABLE_NAME LIKE 'ml\_%' ESCAPE '\\';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    SET FOREIGN_KEY_CHECKS = 0;

    OPEN cur_tables;
    read_loop: LOOP
        FETCH cur_tables INTO v_table;
        IF v_done THEN
            LEAVE read_loop;
        END IF;
        SET @truncate_sql = CONCAT('TRUNCATE TABLE `nascar`.`', v_table, '`');
        PREPARE truncate_stmt FROM @truncate_sql;
        EXECUTE truncate_stmt;
        DEALLOCATE PREPARE truncate_stmt;
    END LOOP;
    CLOSE cur_tables;

    SET FOREIGN_KEY_CHECKS = v_old_fk_checks;
END$$
DELIMITER ;
