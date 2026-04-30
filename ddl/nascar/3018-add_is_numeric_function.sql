DELIMITER //

CREATE OR REPLACE FUNCTION is_numeric(value_to_check VARCHAR(255))
RETURNS TINYINT(1)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_check);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN 0;
    END IF;

    IF cleaned_value REGEXP '^[+-]?[0-9]+(\\.[0-9]+)?$' THEN
        RETURN 1;
    END IF;

    RETURN 0;
END //

DELIMITER ;
