-- sql_format_json_match_value: format a JSON value for substitution into operator ? placeholders.

DROP FUNCTION IF EXISTS `nascar`.`sql_format_json_match_value`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_format_json_match_value`(
    p_json JSON,
    p_value_path TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_value JSON;

    SET p_value = nascar.sql_json_extract_at_path(p_json, p_value_path);

    CASE JSON_TYPE(p_value)
        WHEN 'ARRAY' THEN
            RETURN TRIM(BOTH '[]' FROM REPLACE(REPLACE(REPLACE(CAST(p_value AS CHAR), ' ', ''), '[', ''), ']', ''));
        WHEN 'INTEGER' THEN
            RETURN JSON_UNQUOTE(p_value);
        WHEN 'DOUBLE' THEN
            RETURN JSON_UNQUOTE(p_value);
        WHEN 'STRING' THEN
            RETURN CONCAT('''', REPLACE(JSON_UNQUOTE(p_value), '''', ''''''), '''');
        WHEN 'NULL' THEN
            RETURN 'NULL';
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'sql_format_json_match_value: unsupported JSON value type';
    END CASE;
END$$
DELIMITER ;
