DROP FUNCTION IF EXISTS `nascar`.`sql_build_match_clause_integer`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_build_match_clause_integer`(
    p_json JSON,
    p_key TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_value JSON;

    SET p_value = nascar.sql_json_extract_at_path(p_json, p_key);

    CASE JSON_TYPE(p_value)
        WHEN 'ARRAY' THEN
            RETURN REPLACE(REPLACE(CONCAT('IN ', TRIM(BOTH '[]' FROM REPLACE(p_value, ' ', ''))), '[', '('), ']', ')');
        WHEN 'INTEGER' THEN
            RETURN CONCAT('= ', p_value);
        ELSE
            RETURN '> 0';
    END CASE;
END$$
DELIMITER ;
