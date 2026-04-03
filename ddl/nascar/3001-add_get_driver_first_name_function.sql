DELIMITER //

CREATE OR REPLACE FUNCTION get_driver_first_name(full_name VARCHAR(255))
RETURNS VARCHAR(150) DETERMINISTIC
BEGIN
    RETURN SUBSTRING_INDEX(parse_driver_name_parts(full_name), '|', 1);
END //

DELIMITER ;
