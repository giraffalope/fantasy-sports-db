-- sql_json_extract_at_path: extract a value from JSON using MariaDB JSON Path syntax.
-- p_key may be shorthand (week.operator) or full path ($.week["operator"]); see JSONPath docs.

DROP FUNCTION IF EXISTS `nascar`.`sql_json_extract_at_path`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_json_extract_at_path`(
    p_json JSON,
    p_key TEXT
) RETURNS JSON
    DETERMINISTIC
    COMMENT 'Extract JSON at MariaDB JSON Path. Shorthand keys get $. prefix; full paths starting with $ are used as-is.'
BEGIN
    DECLARE p_path TEXT;
    DECLARE p_message TEXT;

    IF p_key IS NULL OR TRIM(p_key) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_json_extract_at_path: p_key must not be null or empty';
    END IF;

    SET p_path = TRIM(p_key);

    IF LEFT(p_path, 1) <> '$' THEN
        SET p_path = CONCAT('$.', p_path);
    END IF;

    -- MariaDB JSON Path uses ."member" rather than ["member"] for quoted keys.
    IF p_path LIKE '%["%' THEN
        SET p_path = REPLACE(REPLACE(p_path, '["', '."'), '"]', '"');
    END IF;

    IF p_path = '$' OR p_path = '$.' OR p_path LIKE '%..%' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_json_extract_at_path: invalid JSON path';
    END IF;

    IF NOT JSON_CONTAINS_PATH(p_json, 'one', p_path) THEN
        SET p_message = CONCAT('sql_json_extract_at_path: JSON path not found: ', p_path);
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = p_message;
    END IF;

    RETURN JSON_EXTRACT(p_json, p_path);
END$$
DELIMITER ;
