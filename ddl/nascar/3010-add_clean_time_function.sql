DELIMITER //

CREATE OR REPLACE FUNCTION clean_time(time_value VARCHAR(255))
RETURNS TIME(3)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE parsed_time TIME(3);

    SET cleaned_value = TRIM(time_value);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value IN ('0', '0.0', '0.00', '0.000') THEN
        RETURN NULL;
    END IF;

    IF cleaned_value REGEXP '^[0-9]{1,3}:[0-9]{2}:[0-9]{2}(\\.[0-9]{1,6})?$' THEN
        SET parsed_time = CAST(cleaned_value AS TIME(3));
    ELSE
        RETURN NULL;
    END IF;

    IF parsed_time = '00:00:00.000' THEN
        RETURN NULL;
    END IF;

    RETURN parsed_time;
END //

DELIMITER ;
