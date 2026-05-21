-- execute_dynamic_query: calls sql_* query-generator procedures (JSON IN, TEXT OUT),
-- then runs the generated SELECT/WITH statement and returns its result set.
-- Example: CALL nascar.execute_dynamic_query('sql_agg_week_results_query_generation', '{"week_id": 1}');

DROP PROCEDURE IF EXISTS `execute_dynamic_query`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `execute_dynamic_query`(
    IN p_stored_procedure_name VARCHAR(128),
    IN p_json JSON
)
    COMMENT 'Call an nascar.sql_* generator (IN p_json JSON, OUT p_query TEXT), then EXECUTE p_query. Example: CALL nascar.execute_dynamic_query(''sql_agg_week_results_query_generation'', ''{"week_id": 1}'');'
BEGIN
    DECLARE v_procedure_count INT UNSIGNED DEFAULT 0;
    DECLARE v_query_prefix VARCHAR(6);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
            DEALLOCATE PREPARE call_stmt;
            DEALLOCATE PREPARE exec_stmt;
        END;
        RESIGNAL;
    END;

    IF p_stored_procedure_name IS NULL OR TRIM(p_stored_procedure_name) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: p_stored_procedure_name must not be null or empty';
    END IF;

    IF p_stored_procedure_name NOT REGEXP '^[a-zA-Z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: p_stored_procedure_name contains invalid characters';
    END IF;

    IF LEFT(p_stored_procedure_name, 4) <> 'sql_' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: p_stored_procedure_name must start with sql_';
    END IF;

    SELECT COUNT(*)
    INTO v_procedure_count
    FROM information_schema.ROUTINES
    WHERE ROUTINE_SCHEMA = 'nascar'
        AND ROUTINE_NAME = p_stored_procedure_name
        AND ROUTINE_TYPE = 'PROCEDURE';

    IF v_procedure_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: stored procedure not found in nascar schema';
    END IF;

    SET @p_json_in = p_json;
    SET @p_query = NULL;

    SET @call_sql = CONCAT(
        'CALL `nascar`.`', p_stored_procedure_name, '`(?, @p_query)'
    );

    PREPARE call_stmt FROM @call_sql;
    EXECUTE call_stmt USING @p_json_in;
    DEALLOCATE PREPARE call_stmt;

    IF @p_query IS NULL OR TRIM(@p_query) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: generator returned an empty query';
    END IF;

    SET @p_query = TRIM(TRAILING ';' FROM TRIM(@p_query));

    SET v_query_prefix = UPPER(LEFT(TRIM(@p_query), 6));
    IF v_query_prefix <> 'SELECT' AND LEFT(UPPER(TRIM(@p_query)), 4) <> 'WITH' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'execute_dynamic_query: generated query must start with SELECT or WITH';
    END IF;

    PREPARE exec_stmt FROM @p_query;
    EXECUTE exec_stmt;
    DEALLOCATE PREPARE exec_stmt;
END$$
DELIMITER ;
