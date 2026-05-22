-- load_agg_week_manufacturers_results: load agg_week_manufacturers_results for one series/week.
-- Called from nascar.cup.aggregate with p_series_id and p_week_id. Load logic TBD.

DROP PROCEDURE IF EXISTS `load_agg_week_manufacturers_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_manufacturers_results`(
    IN p_series_id BIGINT UNSIGNED,
    IN p_week_id BIGINT UNSIGNED
)
    COMMENT 'Load agg_week_manufacturers_results for p_series_id and p_week_id. Logic TBD.'
BEGIN
    -- Load logic TBD: filter aggregates for p_series_id / p_week_id.
END$$
DELIMITER ;
