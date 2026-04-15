DELIMITER //

CREATE OR REPLACE FUNCTION parse_driver_name_parts(full_name VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE first_part VARCHAR(150) DEFAULT '';
    DECLARE last_part VARCHAR(100) DEFAULT '';
    DECLARE suffix_part VARCHAR(20) DEFAULT '';
    DECLARE clean_name VARCHAR(255);
    DECLARE last_space_pos INT;
    DECLARE comma_count INT DEFAULT 0;
    DECLARE suffix_candidate VARCHAR(30) DEFAULT '';

    SET clean_name = TRIM(full_name);

    -- 1a. Comma-separated suffix (e.g. "Sam Hornish, Jr.")
    SET comma_count = CHAR_LENGTH(clean_name) - CHAR_LENGTH(REPLACE(clean_name, ',', ''));
    IF comma_count >= 1 THEN
        SET suffix_candidate = TRIM(TRAILING '.' FROM TRIM(SUBSTRING_INDEX(clean_name, ',', -1)));
        IF suffix_candidate REGEXP '^(Jr|Sr|III|II|IV|V|MD|PhD|Esq)$' THEN
            SET suffix_part = suffix_candidate;
            SET clean_name = TRIM(SUBSTRING_INDEX(clean_name, ',', comma_count));
        END IF;
    END IF;

    -- 1b. Space-separated suffix (e.g. "Marvin Panch III", "Sam Hornish Jr.")
    IF suffix_part = '' AND clean_name REGEXP ' (Jr\\.?|Sr\\.?|III|II|IV|V|MD|PhD|Esq)$' THEN
        SET suffix_part = TRIM(TRAILING '.' FROM SUBSTRING_INDEX(clean_name, ' ', -1));
        SET clean_name = TRIM(SUBSTRING(clean_name, 1, CHAR_LENGTH(clean_name) - CHAR_LENGTH(SUBSTRING_INDEX(clean_name, ' ', -1))));
    END IF;

    -- 2. Find the last space in the remaining text
    SET last_space_pos = CHAR_LENGTH(clean_name) - CHAR_LENGTH(SUBSTRING_INDEX(clean_name, ' ', -1));

    -- 3. Split into First (including middle names) and Last
    IF last_space_pos > 0 THEN
        SET first_part = TRIM(SUBSTRING(clean_name, 1, last_space_pos));
        SET last_part = TRIM(SUBSTRING(clean_name, last_space_pos + 1));
    ELSE
        SET first_part = clean_name;
        SET last_part = '';
    END IF;

    RETURN CONCAT(first_part, '|', last_part, '|', suffix_part);
END //

DELIMITER ;

-- Verification (run manually after migration):
-- SELECT nascar.parse_driver_name_parts('Sam Hornish, Jr.');   -- expect Sam|Hornish|Jr
-- SELECT nascar.parse_driver_name_parts('Sam Hornish Jr.');    -- expect Sam|Hornish|Jr
-- SELECT nascar.parse_driver_name_parts('Marvin Panch III');   -- Marvin|Panch|III
-- SELECT nascar.parse_driver_name_parts('John Smith MD');     -- John|Smith|MD
-- SELECT nascar.parse_driver_name_parts('Jane Doe');          -- Jane|Doe|
