-- clean_integer: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_integer`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_integer`(value_to_clean VARCHAR(255)) RETURNS int(11)
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_clean);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    IF cleaned_value NOT REGEXP '^-?[0-9]+$' THEN
        RETURN NULL;
    END IF;

    RETURN CAST(cleaned_value AS SIGNED);
END$$
DELIMITER ;
