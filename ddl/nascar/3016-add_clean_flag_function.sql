DELIMITER //

CREATE OR REPLACE FUNCTION clean_flag(flag_value VARCHAR(255))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = UPPER(TRIM(flag_value));

    IF cleaned_value LIKE 'GREEN%' THEN
        RETURN 'GREEN';
    END IF;

    IF cleaned_value LIKE 'YELLOW%' THEN
        RETURN 'YELLOW';
    END IF;

    IF cleaned_value LIKE 'WHITE%' THEN
        RETURN 'WHITE';
    END IF;

    IF cleaned_value LIKE 'CHECKERED%' THEN
        RETURN 'CHECKERED';
    END IF;

    RETURN 'GREEN';
END //

DELIMITER ;
