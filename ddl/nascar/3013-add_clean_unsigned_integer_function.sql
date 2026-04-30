DELIMITER //

CREATE OR REPLACE FUNCTION clean_unsigned_integer(value_to_clean VARCHAR(255))
RETURNS INT UNSIGNED
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_clean);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^[0-9]+$' THEN
        RETURN NULL;
    END IF;

    RETURN CAST(cleaned_value AS UNSIGNED);
END //

DELIMITER ;
