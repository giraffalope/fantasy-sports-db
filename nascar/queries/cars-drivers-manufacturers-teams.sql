-- This query gets cars with drivers, manufacturers and teams and the last race
use nascar;

with car_driver_race_results as (
	select distinct rr.race_id, cd.id as car_driver_id
	from race_results rr
	join cars_drivers cd on rr.car_driver_id = cd.id and cd.deleted_at is null
	where rr.deleted_at is null
),
cars_races as (
	select c.number, d.first_name, d.last_name, d.suffix, m.name as manufacturer_name, t.name as team_name, w.scheduled_start
	from cars c
	join cars_drivers cd on c.id = cd.car_id and cd.deleted_at is null
	join drivers d on cd.driver_id = d.id and d.deleted_at is null
	join manufacturers m on c.manufacturer_id = m.id and m.deleted_at is null
	join teams t on c.team_id = t.id and t.deleted_at is null
	left join car_driver_race_results cdrr on cd.id = cdrr.car_driver_id
	left join races r on cdrr.race_id = r.id and r.deleted_at is null
	left join weeks w on r.week_id = w.id and w.deleted_at is null
	where c.deleted_at is null
)
select number, first_name, last_name, suffix, manufacturer_name, team_name, max(scheduled_start) as last_race_scheduled_start
from cars_races cr
group by number, first_name, last_name, suffix, manufacturer_name, team_name
order by last_race_scheduled_start desc, number, first_name, last_name, suffix, manufacturer_name, team_name
;