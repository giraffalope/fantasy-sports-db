-- load_agg_week_prev_track_car_generations_results: load prior-track aggregate rows for one series/week. Load logic TBD.

DROP PROCEDURE IF EXISTS `load_agg_week_prev_track_car_generations_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_prev_track_car_generations_results`(
    IN p_series_id BIGINT UNSIGNED,
    IN p_week_id BIGINT UNSIGNED
)
    COMMENT 'Load load_agg_week_prev_track_car_generations_results for p_series_id and p_week_id. Logic TBD.'
BEGIN
    -- Load logic TBD: filter aggregates for p_series_id / p_week_id.
END$$
DELIMITER ;

