DELIMITER //

CREATE OR REPLACE FUNCTION clean_name(value_to_clean VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_clean);

    IF is_name(cleaned_value) = 0 THEN
        RETURN NULL;
    END IF;

    SET cleaned_value = REGEXP_REPLACE(cleaned_value, '[[:punct:]]', '');
    SET cleaned_value = TRIM(cleaned_value);

    IF cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    RETURN cleaned_value;
END //

DELIMITER ;
