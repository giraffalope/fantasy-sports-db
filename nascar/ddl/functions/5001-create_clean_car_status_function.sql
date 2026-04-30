-- clean_car_status: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_car_status`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_car_status`(car_status_value VARCHAR(255)) RETURNS varchar(255) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = UPPER(TRIM(car_status_value));

    IF cleaned_value IS NULL OR cleaned_value = '' THEN
        RETURN NULL;
    END IF;

    RETURN cleaned_value;
END$$
DELIMITER ;
