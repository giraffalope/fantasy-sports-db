-- clean_manufacturer_name: function used by NASCAR ingest, enrichment, and analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP FUNCTION IF EXISTS `clean_manufacturer_name`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `clean_manufacturer_name`(manufacturer_name VARCHAR(255)) RETURNS varchar(20) CHARSET utf8mb4 COLLATE utf8mb4_uca1400_ai_ci
    DETERMINISTIC
BEGIN
    DECLARE cleaned_value VARCHAR(255);
    DECLARE upper_value VARCHAR(255);

    SET cleaned_value = clean_name(manufacturer_name);

    SET upper_value = UPPER(cleaned_value);

    IF upper_value = 'CHEVROLET' THEN
        RETURN 'Chevrolet';
    END IF;

    IF upper_value = 'FORD' THEN
        RETURN 'Ford';
    END IF;

    IF upper_value = 'TOYOTA' THEN
        RETURN 'Toyota';
    END IF;

    IF upper_value = 'DODGE' THEN
        RETURN 'Dodge';
    END IF;

    RETURN NULL;
END$$
DELIMITER ;
