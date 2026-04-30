-- get_driver_suffix: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `get_driver_suffix`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_driver_suffix`(full_name VARCHAR(255)) RETURNS varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    RETURN SUBSTRING_INDEX(parse_driver_name_parts(full_name), '|', -1);
END$$
DELIMITER ;
