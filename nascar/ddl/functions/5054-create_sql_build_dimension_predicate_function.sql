-- sql_build_dimension_predicate: WHERE predicate for one dimension from nested filter JSON.
-- If p_filter_path exists (e.g. week, season), uses sql_build_match_clause and maps {{id}} to p_column_sql.
-- If omitted, returns "column > 0" for unrestricted CTE filtering.

DROP FUNCTION IF EXISTS `nascar`.`sql_build_dimension_predicate`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `nascar`.`sql_build_dimension_predicate`(
    p_json JSON,
    p_filter_path TEXT,
    p_column_sql TEXT
) RETURNS TEXT CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE p_json_path TEXT;
    DECLARE p_clause TEXT;

    IF p_filter_path IS NULL OR TRIM(p_filter_path) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_dimension_predicate: p_filter_path must not be null or empty';
    END IF;

    IF p_column_sql IS NULL OR TRIM(p_column_sql) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'sql_build_dimension_predicate: p_column_sql must not be null or empty';
    END IF;

    SET p_json_path = TRIM(p_filter_path);
    IF LEFT(p_json_path, 1) = '$' THEN
        SET p_json_path = SUBSTRING(p_json_path, 2);
    END IF;

    IF JSON_CONTAINS_PATH(p_json, 'one', CONCAT('$.', p_json_path)) THEN
        SET p_clause = nascar.sql_build_match_clause(p_json, p_filter_path, NULL);
        RETURN REPLACE(p_clause, '{{id}}', TRIM(p_column_sql));
    END IF;

    RETURN CONCAT(TRIM(p_column_sql), ' > 0');
END$$
DELIMITER ;
