DELIMITER //

CREATE OR REPLACE FUNCTION clean_car_status(car_status_value VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = UPPER(TRIM(car_status_value));

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    RETURN cleaned_value;
END //

DELIMITER ;
