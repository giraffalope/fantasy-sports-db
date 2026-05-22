DROP PROCEDURE IF EXISTS `load_agg_week_prev_track_teams_results`;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `load_agg_week_prev_track_teams_results`(
    IN p_series_id BIGINT UNSIGNED,
    IN p_week_id BIGINT UNSIGNED
)
    COMMENT 'Aggregate prior-track team-level stats for a race week into agg_week_prev_track_teams_results. Logic TBD.'
BEGIN
    -- Implement aggregation for p_week_id (insert/update agg_week_prev_track_teams_results).

    with current_week as (
        select s.series_id, w.id as week_id, w.track_id
        from nascar.weeks w
        join nascar.seasons s on w.season_id = s.id and s.deleted_at is null
        join nascar.tracks t on w.track_id = t.id and t.deleted_at is null
        where w.deleted_at IS NULL
          and s.series_id = p_series_id
          and w.id = p_week_id
    ),
    prior_weeks as (
        select s.series_id, w.id as week_id, w.track_id
        from nascar.weeks w
		join nascar.seasons s on w.season_id = s.id and s.deleted_at is null
        join current_week cw on w.track_id = cw.track_id
        where w.deleted_at IS NULL
        and s.series_id = p_series_id
        and w.id < p_week_id
    ),
    agg_week_results as (
        select awr.*
        from agg_week_results awr
        join prior_weeks pw on awr.week_id = pw.week_id
    )
    select *
    from agg_week_results awr
    order by awr.series_id, awr.season_id, awr.week_id, awr.track_id, awr.race_id, awr.r_finish_position
	;
END$$
DELIMITER ;
