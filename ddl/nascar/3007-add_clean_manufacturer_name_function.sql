DELIMITER //

CREATE OR REPLACE FUNCTION clean_manufacturer_name(manufacturer_name VARCHAR(255))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE upper_value VARCHAR(255);

    SET cleaned_value = clean_name(manufacturer_name);

    SET upper_value = UPPER(cleaned_value);

    IF upper_value = 'CHEVROLET' THEN
        RETURN 'Chevrolet';
    END IF;

    IF upper_value = 'FORD' THEN
        RETURN 'Ford';
    END IF;

    IF upper_value = 'TOYOTA' THEN
        RETURN 'Toyota';
    END IF;

    IF upper_value = 'DODGE' THEN
        RETURN 'Dodge';
    END IF;

    RETURN NULL;
END //

DELIMITER ;
