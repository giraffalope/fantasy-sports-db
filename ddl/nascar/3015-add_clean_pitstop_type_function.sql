DELIMITER //

CREATE OR REPLACE FUNCTION clean_pitstop_type(pitstop_type_value VARCHAR(255))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = UPPER(TRIM(pitstop_type_value));

    IF cleaned_value LIKE '%RIGHT%' THEN
        RETURN 'TWO_WHEEL_CHANGE_RIGHT';
    END IF;

    IF cleaned_value LIKE '%LEFT%' THEN
        RETURN 'TWO_WHEEL_CHANGE_LEFT';
    END IF;

    RETURN 'FOUR_WHEEL_CHANGE';
END //

DELIMITER ;
