-- v_series_before_current_week: P/Q/R-active weeks strictly before each series' current week.
-- Depends on v_series_current_week. Ordering matches current week:
-- (season_year, week_number, week_season_number).

DROP VIEW IF EXISTS `v_dfs_race_lineups_overview`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dfs_race_lineups_overview` AS
with dfs_lineups as (
    select 
        drl.id as dfs_race_lineup_id,
        drl.dfs_id as dfs_id,
        drl.race_id as race_id,
        drl.strategy as strategy,
        drl.projected_points_total as projected_points_total,
        drl.salary_total as salary_total
    from dfs_race_lineups drl
    where drl.deleted_at is null
),
dfs_lineup_drivers as (
    select
        drlcd.dfs_race_lineup_id as dfs_race_lineup_id,
        drlcd.dfs_driver_id as dfs_driver_id,
        cd.car_id as car_id,
        d.id as driver_id,
        trim(concat(d.first_name, ' ', d.last_name, ' ', ifnull(d.suffix, ''))) as driver_name,
        drlcd.salary as salary,
        drlcd.projected_points as projected_points
    from dfs_race_lineups_car_drivers drlcd 
    join cars_drivers cd on cd.id = drlcd.car_driver_id and cd.deleted_at is null
	join drivers d on cd.driver_id = d.id and drlcd.deleted_at is null
    where d.deleted_at is null
)
select *
from dfs_lineups dl
join dfs_lineup_drivers dld using (dfs_race_lineup_id)
order by dl.race_id, dl.projected_points_total desc, dl.salary_total asc, dld.projected_points desc, dld.salary asc
;