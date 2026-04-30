DELIMITER //

CREATE OR REPLACE FUNCTION clean_speed(speed_value VARCHAR(255))
RETURNS DECIMAL(8,3) UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE parsed_speed DECIMAL(8,3) UNSIGNED;

    SET cleaned_value = TRIM(speed_value);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN
        RETURN NULL;
    END IF;

    SET parsed_speed = ROUND(CAST(cleaned_value AS DECIMAL(8,4)), 3);

    IF parsed_speed = 0 THEN
        RETURN NULL;
    END IF;

    RETURN parsed_speed;
END//

DELIMITER ;