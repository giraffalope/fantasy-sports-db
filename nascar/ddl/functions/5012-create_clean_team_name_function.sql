-- clean_team_name: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_team_name`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_team_name`(team_name VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    RETURN clean_name(team_name);
END$$
DELIMITER ;
