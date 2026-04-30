-- clean_string: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_string`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_string`(value_to_clean VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    RETURN NULLIF(TRIM(value_to_clean), '');
END$$
DELIMITER ;
