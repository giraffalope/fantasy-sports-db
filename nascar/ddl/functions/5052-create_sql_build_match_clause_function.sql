-- sql_build_match_clause: build AND-joined condition fragments from JSON filters.
-- JSON contract: filter path -> object or array of objects, each with operator/op + one value sibling.
-- Output uses {{value_key}} placeholders for column names (replace before final SQL).
-- Example: sql_build_match_clause(p_json, 'week', NULL)
--   -> {{id}} IN (1,2,3) AND {{number}} NOT IN (1,2)

DROP FUNCTION IF EXISTS `nascar`.`sql_build_match_clause`;
DROP FUNCTION IF EXISTS `nascar`.`sql_build_match_clause_one`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_build_match_clause_one`(
    p_json JSON,
    p_object_path TEXT,
    p_value_key TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_json_path TEXT;
    DECLARE p_operator_path TEXT;
    DECLARE p_keys JSON;
    DECLARE p_predicate TEXT;
    DECLARE p_value_path TEXT;
    DECLARE p_formatted_value TEXT;
    DECLARE p_key_name TEXT;
    DECLARE p_resolved_value_key TEXT;
    DECLARE p_key_count INT UNSIGNED DEFAULT 0;
    DECLARE p_non_operator_count INT UNSIGNED DEFAULT 0;
    DECLARE p_i INT UNSIGNED DEFAULT 0;

    IF p_object_path IS NULL OR TRIM(p_object_path) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_match_clause_one: p_object_path must not be null or empty';
    END IF;

    SET p_json_path = TRIM(p_object_path);
    IF LEFT(p_json_path, 1) <> '$' THEN
        SET p_json_path = CONCAT('$.', p_json_path);
    END IF;
    IF p_json_path LIKE '%["%' THEN
        SET p_json_path = REPLACE(REPLACE(p_json_path, '["', '."'), '"]', '"');
    END IF;

    IF NOT JSON_CONTAINS_PATH(p_json, 'one', p_json_path) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_match_clause_one: filter object path not found';
    END IF;

    SET p_operator_path = NULL;
    IF JSON_CONTAINS_PATH(p_json, 'one', CONCAT(p_json_path, '.operator')) THEN
        SET p_operator_path = CONCAT(TRIM(p_object_path), '.operator');
    ELSEIF JSON_CONTAINS_PATH(p_json, 'one', CONCAT(p_json_path, '.op')) THEN
        SET p_operator_path = CONCAT(TRIM(p_object_path), '.op');
    ELSE
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_match_clause_one: operator or op key required';
    END IF;

    SET p_predicate = nascar.sql_build_match_clause_operator(p_json, p_operator_path);

    IF p_value_key IS NOT NULL AND TRIM(p_value_key) <> '' THEN
        SET p_resolved_value_key = TRIM(p_value_key);
    ELSE
        SET p_keys = JSON_KEYS(p_json, p_json_path);
        SET p_key_count = JSON_LENGTH(p_keys);

        WHILE p_i < p_key_count DO
            SET p_key_name = JSON_UNQUOTE(JSON_EXTRACT(p_keys, CONCAT('$[', p_i, ']')));

            IF p_key_name NOT IN ('operator', 'op') THEN
                SET p_non_operator_count = p_non_operator_count + 1;
                SET p_resolved_value_key = p_key_name;
            END IF;

            SET p_i = p_i + 1;
        END WHILE;

        IF p_non_operator_count = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'sql_build_match_clause_one: value key required (pass p_value_key)';
        END IF;

        IF p_non_operator_count > 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'sql_build_match_clause_one: ambiguous value key in filter object';
        END IF;
    END IF;

    IF LOCATE('?', p_predicate) > 0 THEN
        SET p_value_path = CONCAT(TRIM(p_object_path), '.', p_resolved_value_key);
        SET p_formatted_value = nascar.sql_format_json_match_value(p_json, p_value_path);
        SET p_predicate = REPLACE(p_predicate, '?', p_formatted_value);
    END IF;

    RETURN CONCAT('{{', p_resolved_value_key, '}} ', p_predicate);
END$$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_build_match_clause`(
    p_json JSON,
    p_filter_path TEXT,
    p_value_key TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_filter JSON;
    DECLARE p_result TEXT;
    DECLARE p_clause TEXT;
    DECLARE p_elem_path TEXT;
    DECLARE p_array_len INT UNSIGNED;
    DECLARE p_i INT UNSIGNED DEFAULT 0;

    IF p_filter_path IS NULL OR TRIM(p_filter_path) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_match_clause: p_filter_path must not be null or empty';
    END IF;

    SET p_filter = nascar.sql_json_extract_at_path(p_json, p_filter_path);

    CASE JSON_TYPE(p_filter)
        WHEN 'OBJECT' THEN
            RETURN nascar.sql_build_match_clause_one(p_json, p_filter_path, p_value_key);
        WHEN 'ARRAY' THEN
            SET p_array_len = JSON_LENGTH(p_filter);

            IF p_array_len = 0 THEN
                SIGNAL SQLSTATE '45000'
                    SET MESSAGE_TEXT = 'sql_build_match_clause: filter array must not be empty';
            END IF;

            WHILE p_i < p_array_len DO
                SET p_elem_path = CONCAT(TRIM(p_filter_path), '[', p_i, ']');
                SET p_clause = nascar.sql_build_match_clause_one(p_json, p_elem_path, NULL);

                IF p_result IS NULL THEN
                    SET p_result = p_clause;
                ELSE
                    SET p_result = CONCAT(p_result, ' AND ', p_clause);
                END IF;

                SET p_i = p_i + 1;
            END WHILE;

            RETURN p_result;
        ELSE
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'sql_build_match_clause: filter must be a JSON object or array';
    END CASE;
END$$
DELIMITER ;
