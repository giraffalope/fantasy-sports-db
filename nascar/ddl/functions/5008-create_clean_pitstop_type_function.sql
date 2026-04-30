-- clean_pitstop_type: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_pitstop_type`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_pitstop_type`(pitstop_type_value VARCHAR(255)) RETURNS varchar(30) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
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
END$$
DELIMITER ;
