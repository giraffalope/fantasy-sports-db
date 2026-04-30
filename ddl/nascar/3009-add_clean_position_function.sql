DELIMITER //

CREATE OR REPLACE FUNCTION clean_position(position_value VARCHAR(255))
RETURNS TINYINT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE numeric_value INT UNSIGNED;

    SET cleaned_value = TRIM(position_value);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^[0-9]+$' THEN
        RETURN NULL;
    END IF;

    SET numeric_value = CAST(cleaned_value AS UNSIGNED);

    IF numeric_value = 0 OR numeric_value >= 100 THEN
        RETURN NULL;
    END IF;

    RETURN CAST(numeric_value AS UNSIGNED);
END //

DELIMITER ;
