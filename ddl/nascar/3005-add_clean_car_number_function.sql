DELIMITER //

CREATE OR REPLACE FUNCTION clean_car_number(car_number VARCHAR(255))
RETURNS VARCHAR(2)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(car_number);

    IF cleaned_value IS NULL OR cleaned_value = '' OR UPPER(cleaned_value) IN ('N/A', 'NONE', 'UNKNOWN')  THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^[0-9]+$' THEN
        RETURN NULL;
    END IF;

    RETURN RIGHT(cleaned_value, 2);
END //

DELIMITER ;
