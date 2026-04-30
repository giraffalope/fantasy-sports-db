DELIMITER //

CREATE OR REPLACE FUNCTION clean_decimal(value_to_clean VARCHAR(255))
RETURNS DECIMAL(8,3)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE parsed_value DECIMAL(8,4);

    SET cleaned_value = TRIM(value_to_clean);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^-?[0-9]+(\\.[0-9]+)?$' THEN
        RETURN NULL;
    END IF;

    SET parsed_value = CAST(cleaned_value AS DECIMAL(8,4));

    RETURN ROUND(parsed_value, 3);
END //

DELIMITER ;
