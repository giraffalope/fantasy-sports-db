-- clean_car_number: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_car_number`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_car_number`(car_number VARCHAR(255)) RETURNS varchar(2) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(car_number);

    IF cleaned_value IS NULL OR cleaned_value = '' OR UPPER(cleaned_value) IN ('N/A', 'NONE', 'UNKNOWN')  THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^[0-9]+$' THEN
        RETURN NULL;
    END IF;

    RETURN RIGHT(cleaned_value, 2);
END$$
DELIMITER ;
