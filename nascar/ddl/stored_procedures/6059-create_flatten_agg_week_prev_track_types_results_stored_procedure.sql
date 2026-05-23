-- flatten_agg_week_prev_track_types_results: pivot agg_week_prev_track_types_* rows by track_type_id.
-- One wide row per entity grain (series/season/week + dimension *_id columns); metrics become tt_{track_type_id}_{column}.
-- Pivot axis: distinct track_type_id values present for (p_series_id, p_week_id). Returns a result set.

DROP PROCEDURE IF EXISTS `flatten_agg_week_prev_track_types_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `flatten_agg_week_prev_track_types_results`(
    IN p_series_id BIGINT UNSIGNED,
    IN p_week_id BIGINT UNSIGNED,
    IN p_table_name VARCHAR(128)
)
    COMMENT 'Pivot agg_week_prev_track_types_* long rows into wide rows with tt_{track_type_id}_{metric} columns for a series/week.'
BEGIN
    DECLARE v_grain_list LONGTEXT DEFAULT NULL;
    DECLARE v_select_parts LONGTEXT DEFAULT NULL;
    DECLARE v_sql LONGTEXT DEFAULT NULL;
    DECLARE v_table_count INT UNSIGNED DEFAULT 0;
    DECLARE v_track_type_count INT UNSIGNED DEFAULT 0;
    DECLARE v_track_type_id BIGINT UNSIGNED;
    DECLARE v_col_name VARCHAR(64);
    DECLARE v_done_track_types INT DEFAULT FALSE;

    DECLARE cur_track_types CURSOR FOR
        SELECT track_type_id
        FROM tmp_flatten_track_types
        ORDER BY track_type_id;

    DECLARE cur_metrics CURSOR FOR
        SELECT col_name
        FROM tmp_flatten_metrics
        ORDER BY sort_order;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done_track_types = TRUE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        BEGIN
            DECLARE CONTINUE HANDLER FOR SQLEXCEPTION BEGIN END;
            DEALLOCATE PREPARE flatten_discover_track_types_stmt;
            DEALLOCATE PREPARE flatten_exec_stmt;
        END;
        DROP TEMPORARY TABLE IF EXISTS tmp_flatten_track_types;
        DROP TEMPORARY TABLE IF EXISTS tmp_flatten_metrics;
        RESIGNAL;
    END;

    IF p_series_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: p_series_id must not be null';
    END IF;

    IF p_week_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: p_week_id must not be null';
    END IF;

    IF p_table_name IS NULL OR TRIM(p_table_name) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: p_table_name must not be null or empty';
    END IF;

    IF p_table_name NOT REGEXP '^agg_week_prev_track_types_[a-z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: p_table_name is not an allowed agg_week_prev_track_types_* table';
    END IF;

    SELECT COUNT(*)
    INTO v_table_count
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = 'nascar'
        AND TABLE_NAME = p_table_name
        AND TABLE_TYPE = 'BASE TABLE';

    IF v_table_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: table not found in nascar schema';
    END IF;

    SELECT GROUP_CONCAT(CONCAT('`', COLUMN_NAME, '`') ORDER BY ORDINAL_POSITION SEPARATOR ', ')
    INTO v_grain_list
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'nascar'
        AND TABLE_NAME = p_table_name
        AND COLUMN_NAME REGEXP '_id$'
        AND COLUMN_NAME NOT IN ('id', 'track_type_id');

    IF v_grain_list IS NULL OR TRIM(v_grain_list) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'flatten_agg_week_prev_track_types_results: no grain columns found on table';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_flatten_metrics;
    CREATE TEMPORARY TABLE tmp_flatten_metrics (
        col_name VARCHAR(64) NOT NULL PRIMARY KEY,
        sort_order INT UNSIGNED NOT NULL
    );

    INSERT INTO tmp_flatten_metrics (col_name, sort_order)
    SELECT COLUMN_NAME, ORDINAL_POSITION
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = 'nascar'
        AND TABLE_NAME = p_table_name
        AND COLUMN_NAME NOT IN ('id', 'track_type_id', 'created_at', 'updated_at', 'deleted_at')
        AND NOT (
            COLUMN_NAME REGEXP '_id$'
            AND COLUMN_NAME NOT IN ('id', 'track_type_id')
        )
    ORDER BY ORDINAL_POSITION;

    DROP TEMPORARY TABLE IF EXISTS tmp_flatten_track_types;
    CREATE TEMPORARY TABLE tmp_flatten_track_types (
        track_type_id BIGINT UNSIGNED NOT NULL PRIMARY KEY
    );

    SET @flatten_discover_track_types_sql = CONCAT(
        'INSERT INTO tmp_flatten_track_types (track_type_id) ',
        'SELECT DISTINCT track_type_id ',
        'FROM nascar.`', p_table_name, '` ',
        'WHERE series_id = ', p_series_id,
        ' AND week_id = ', p_week_id,
        ' AND deleted_at IS NULL ',
        'ORDER BY track_type_id'
    );

    PREPARE flatten_discover_track_types_stmt FROM @flatten_discover_track_types_sql;
    EXECUTE flatten_discover_track_types_stmt;
    DEALLOCATE PREPARE flatten_discover_track_types_stmt;

    SELECT COUNT(*)
    INTO v_track_type_count
    FROM tmp_flatten_track_types;

    IF v_track_type_count = 0 THEN
        SET v_sql = CONCAT(
            'SELECT ', v_grain_list,
            ' FROM nascar.`', p_table_name, '` ',
            'WHERE 1 = 0'
        );
    ELSE
        SET v_select_parts = v_grain_list;
        SET v_done_track_types = FALSE;

        OPEN cur_track_types;

        track_types_loop: LOOP
            FETCH cur_track_types INTO v_track_type_id;
            IF v_done_track_types THEN
                LEAVE track_types_loop;
            END IF;

            BEGIN
                DECLARE v_done_metrics INT DEFAULT FALSE;
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done_metrics = TRUE;

                OPEN cur_metrics;

                metrics_loop: LOOP
                    FETCH cur_metrics INTO v_col_name;
                    IF v_done_metrics THEN
                        LEAVE metrics_loop;
                    END IF;

                    SET v_select_parts = CONCAT(
                        v_select_parts,
                        ', MAX(CASE WHEN track_type_id = ', v_track_type_id,
                        ' THEN `', v_col_name, '` END) AS `tt_',
                        v_track_type_id, '_', v_col_name, '`'
                    );
                END LOOP metrics_loop;

                CLOSE cur_metrics;
            END;
        END LOOP track_types_loop;

        CLOSE cur_track_types;

        SET v_sql = CONCAT(
            'SELECT ', v_select_parts,
            ' FROM nascar.`', p_table_name, '` ',
            'WHERE series_id = ', p_series_id,
            ' AND week_id = ', p_week_id,
            ' AND deleted_at IS NULL ',
            'GROUP BY ', v_grain_list
        );
    END IF;

    SET @flatten_exec_sql = v_sql;
    PREPARE flatten_exec_stmt FROM @flatten_exec_sql;
    EXECUTE flatten_exec_stmt;
    DEALLOCATE PREPARE flatten_exec_stmt;

    DROP TEMPORARY TABLE IF EXISTS tmp_flatten_track_types;
    DROP TEMPORARY TABLE IF EXISTS tmp_flatten_metrics;
END$$
DELIMITER ;
