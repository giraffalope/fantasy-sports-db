-- clean_name: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_name`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_name`(value_to_clean VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
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
END$$
DELIMITER ;
