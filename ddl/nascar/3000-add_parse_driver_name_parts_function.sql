DELIMITER //

CREATE OR REPLACE FUNCTION parse_driver_name_parts(full_name VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE first_part VARCHAR(150) DEFAULT '';
    DECLARE last_part  VARCHAR(100) DEFAULT '';
    DECLARE suffix_part VARCHAR(20)  DEFAULT '';
    DECLARE clean_name  VARCHAR(255);
    DECLARE last_space_pos INT;
    
    SET clean_name = TRIM(full_name);

    -- 1. Identify and Extract Suffix (e.g., Jr, Sr, II, III, IV, V)
    -- Using REGEXP to ensure it only matches if it's a standalone word at the end
    IF clean_name REGEXP ' (Jr|Sr|II|III|IV|V|MD|PhD|Esq)$' THEN
        SET suffix_part = SUBSTRING_INDEX(clean_name, ' ', -1);
        -- Trim the suffix off the name to find the 'real' last name
        SET clean_name = TRIM(SUBSTRING(clean_name, 1, CHAR_LENGTH(clean_name) - CHAR_LENGTH(suffix_part)));
    END IF;

    -- 2. Find the last space in the remaining text
    -- This handles "Bobby Joe Williams" -> "Williams" is the last space index
    SET last_space_pos = CHAR_LENGTH(clean_name) - CHAR_LENGTH(SUBSTRING_INDEX(clean_name, ' ', -1));

    -- 3. Split into First (including middle names) and Last
    IF last_space_pos > 0 THEN
        SET first_part = TRIM(SUBSTRING(clean_name, 1, last_space_pos));
        SET last_part  = TRIM(SUBSTRING(clean_name, last_space_pos + 1));
    ELSE
        -- Single word names (e.g., "Cher")
        SET first_part = clean_name;
        SET last_part  = '';
    END IF;

    -- Return as pipe-delimited: First|Last|Suffix
    RETURN CONCAT(first_part, '|', last_part, '|', suffix_part);
END //

DELIMITER ;