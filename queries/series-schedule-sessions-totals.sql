-- This query gets the number of practices, qualifyings, races per week for each season of a series 

use nascar;

with schedule as (
	select s.name, se.year, w.number, w.season_number, t.name as track_name, w.race_name, w.scheduled_start, w.id as week_id
	from series s
	join seasons se on s.id = se.series_id
	join weeks w on se.id = w.season_id
	join tracks t on w.track_id = t.id
	where s.name = 'Cup'
	order by se.year, w.number, w.season_number
),
practices as (
	select distinct week_id, pr.practice_id
    from schedule s
    right join practices p using (week_id)
    right join practice_results pr on p.id = pr.practice_id
    group by 1, 2
),
total_practices as (
	select p.week_id, count(*) as total_practices
    from practices p
    group by 1
),
qualifyings as (
	select distinct week_id, qr.qualifying_id
    from schedule s
    right join qualifyings q using (week_id)
    right join qualifying_results qr on q.id = qr.qualifying_id
    group by 1, 2
),
total_qualifyings as (
	select q.week_id, count(*) as total_qualifyings
    from qualifyings q
    group by 1
),
races as (
	select distinct week_id, rr.race_id
    from schedule s
    right join races r using (week_id)
    right join race_results rr on r.id = rr.race_id
    group by 1, 2
),
total_races as (
	select r.week_id, count(*) as total_races
    from races r
    group by 1
),
penalties as (
	select distinct p.race_id, r.week_id
    from penalties p
    right join races r using (race_id)
),
pitstops as (
	select distinct p.race_id, r.week_id
    from pitstops p
    right join races r using (race_id)
)
select s.*, ifnull(tp.total_practices, 0) as total_practices, ifnull(tq.total_qualifyings, 0) as total_qualifyings, ifnull(tr.total_races, 0) as total_races, ifnull(if(pen.race_id, true, false), false) as has_penalty_data, ifnull(if(pit.race_id, true, false), false) as has_pitstop_data
from schedule s
left join total_practices tp using (week_id)
left join total_qualifyings tq using (week_id)
right join total_races tr using (week_id)
left join penalties pen using (week_id)
left join pitstops pit using (week_id)
order by year, number
;


