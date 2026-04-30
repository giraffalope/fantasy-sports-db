-- is_numeric: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `is_numeric`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `is_numeric`(value_to_check VARCHAR(255)) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_check);

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN 0;
    END IF;

    IF cleaned_value REGEXP '^[+-]?[0-9]+(\\\\.[0-9]+)?$' THEN
        RETURN 1;
    END IF;

    RETURN 0;
END$$
DELIMITER ;
