with schedule as (
	select s.name, se.year, w.number, w.season_number, t.name as track_name , t.id as track_id, w.race_name, w.scheduled_start, w.id as week_id
	from series s
	join seasons se on s.id = se.series_id
	join weeks w on se.id = w.season_id
	join tracks t on w.track_id = t.id
	where s.name = 'Cup'
	order by se.year, w.number, w.season_number
),
qualifying_results_adj as (
	select s.name, s.year, s.number, s.season_number, s.track_name , s.track_id, s.race_name, s.scheduled_start, s.week_id, qr.*, rank() over (partition by qr.qualifying_id order by best_time asc, best_speed desc) as rnk
    from qualifying_results qr
    join qualifyings q on qr.qualifying_id = q.id
    join schedule s using (week_id)
)
-- Now these might come out different for the years where Nascar tried to copy F1 qualifyings. I could speed up with normal join but want to verify the data linkages are correct
select qra.name, qra.year, qra.number, qra.season_number, qra.track_name, qra.track_id, qra.race_name, qra.scheduled_start, qra.week_id, qra.qualifying_id, d.first_name, d.last_name, d.suffix, c.number, m.name as manufacturer, qra.finish_position, qra.rnk, qra.best_time, qra.best_speed
from qualifying_results_adj qra
left join cars_drivers cd on qra.car_driver_id = cd.id
left join cars c on cd.car_id = c.id
left join drivers d on cd.driver_id = d.id
left join manufacturers m on c.manufacturer_id = m.id
where qra.rnk != finish_position
;

-- oh its a bad join isn't it