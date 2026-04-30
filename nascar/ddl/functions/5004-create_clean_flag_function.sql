-- clean_flag: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_flag`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_flag`(flag_value VARCHAR(255)) RETURNS varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);

    SET cleaned_value = UPPER(TRIM(flag_value));

    IF cleaned_value LIKE 'GREEN%' THEN
        RETURN 'GREEN';
    END IF;

    IF cleaned_value LIKE 'YELLOW%' THEN
        RETURN 'YELLOW';
    END IF;

    IF cleaned_value LIKE 'WHITE%' THEN
        RETURN 'WHITE';
    END IF;

    IF cleaned_value LIKE 'CHECKERED%' THEN
        RETURN 'CHECKERED';
    END IF;

    RETURN 'GREEN';
END$$
DELIMITER ;
