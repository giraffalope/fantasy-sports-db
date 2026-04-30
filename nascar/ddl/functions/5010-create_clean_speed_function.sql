-- clean_speed: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_speed`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_speed`(speed_value VARCHAR(255)) RETURNS decimal(8,3) unsigned
    DETERMINISTIC
BEGIN
    RETURN clean_unsigned_decimal(speed_value);
END$$
DELIMITER ;
