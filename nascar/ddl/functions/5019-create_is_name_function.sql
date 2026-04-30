-- is_name: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `is_name`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `is_name`(value_to_check VARCHAR(255)) RETURNS tinyint(1)
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = TRIM(value_to_check);

    IF cleaned_value IS NULL
        OR cleaned_value = ''
        OR UPPER(cleaned_value) IN ('N/A', 'NONE', 'UNKNOWN')
        OR is_numeric(cleaned_value) = 1
    THEN
        RETURN 0;
    END IF;

    RETURN 1;
END$$
DELIMITER ;
