-- sql_build_match_clause_operator: maps JSON operator strings to SQL comparison fragments.
-- p_key: MariaDB JSON Path (week.operator, $.week["operator"], series_id, ...).
-- Supports long names, abbreviations (eq, gte, isnull, nn), and in/not_in as IN (?)/NOT IN (?).

DROP FUNCTION IF EXISTS `nascar`.`sql_build_match_clause_operator`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_build_match_clause_operator`(
    p_json JSON,
    p_key TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_value JSON;
    DECLARE p_operator TEXT;

    SET p_value = nascar.sql_json_extract_at_path(p_json, p_key);

    IF JSON_TYPE(p_value) = 'NULL' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_match_clause_operator: operator value is JSON null';
    END IF;

    CASE JSON_TYPE(p_value)
        WHEN 'STRING' THEN
            SET p_operator = JSON_UNQUOTE(p_value);

            CASE p_operator
                WHEN 'in' THEN RETURN 'IN (?)';
                WHEN 'not_in' THEN RETURN 'NOT IN (?)';
                WHEN 'ni' THEN RETURN 'NOT IN (?)';
                WHEN 'equal' THEN RETURN '= ?';
                WHEN 'eq' THEN RETURN '= ?';
                WHEN 'not_equal' THEN RETURN '!= ?';
                WHEN 'ne' THEN RETURN '!= ?';
                WHEN 'neq' THEN RETURN '!= ?';
                WHEN 'greater_than' THEN RETURN '> ?';
                WHEN 'gt' THEN RETURN '> ?';
                WHEN 'less_than' THEN RETURN '< ?';
                WHEN 'lt' THEN RETURN '< ?';
                WHEN 'greater_than_or_equal' THEN RETURN '>= ?';
                WHEN 'gte' THEN RETURN '>= ?';
                WHEN 'less_than_or_equal' THEN RETURN '<= ?';
                WHEN 'lte' THEN RETURN '<= ?';
                WHEN 'is_null' THEN RETURN 'IS NULL';
                WHEN 'isnull' THEN RETURN 'IS NULL';
                WHEN 'is_not_null' THEN RETURN 'IS NOT NULL';
                WHEN 'isnotnull' THEN RETURN 'IS NOT NULL';
                WHEN 'nn' THEN RETURN 'IS NOT NULL';
                ELSE
                    SIGNAL SQLSTATE '45000'
                        SET MESSAGE_TEXT = 'sql_build_match_clause_operator: unknown operator';
            END CASE;
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'sql_build_match_clause_operator: operator must be a JSON string';
    END CASE;
END$$
DELIMITER ;
