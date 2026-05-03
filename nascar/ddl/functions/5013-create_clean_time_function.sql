-- clean_time: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_time`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_time`(time_value VARCHAR(255)) RETURNS time(3)
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE parsed_time TIME(3);

    SET cleaned_value = TRIM(time_value);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value IN ('0', '0.0', '0.00', '0.000') THEN
        RETURN NULL;
    END IF;

    -- H:MM:SS or HH:MM:SS with optional fractional seconds (e.g. qualifying / practice CSV).
    IF cleaned_value REGEXP '^[0-9]{1,3}:[0-9]{2}:[0-9]{2}(\\.[0-9]{1,6})?$' THEN
        SET parsed_time = CAST(cleaned_value AS TIME(3));
    -- Plain seconds as integer or decimal (e.g. pit JSON: 61.123 -> 00:01:01.123).
    ELSEIF cleaned_value REGEXP '^[0-9]+(\\.[0-9]+)?$' THEN
        SET parsed_time = CAST(SEC_TO_TIME(CAST(cleaned_value AS DECIMAL(20, 6))) AS TIME(3));
    ELSE
        RETURN NULL;
    END IF;

    IF parsed_time = '00:00:00.000' THEN
        RETURN NULL;
    END IF;

    RETURN parsed_time;
END$$
DELIMITER ;
