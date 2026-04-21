use nascar;
call week_results(1, 16, 992);

select rr.*
from race_results rr
join races r on rr.race_id = r.id
join weeks w on r.week_id = w.id
where w.id = 992
order by rr.finish_position
;

select upper(rr.car_status), count(*)
from race_results rr
group by upper(rr.car_status)
;

-- These all seem to be special events with bad car status data (Daytona Duels, All-Star, Clash, Bristol Dirt (most likely heat races)
-- maybe add a special flag to the race table that denotes is_special_event, or enum type that is event_type (Regular, Daytona Duel, All-Star, Clash, Heat)
select s.year, w.number, w.season_number, w.race_name, rr.*
from race_results rr
join races r on rr.race_id = r.id
join weeks w on r.week_id = w.id
join seasons s on w.season_id = s.id
where rr.car_status like '%stage%' or rr.car_status is null
;

-- Handful of rows that are not special events with incomplete data (2012 week 23 Pure Michigan 400, 2017 32 Hollywood Casino 400, 2024 40 Xfinity 500)
select s.year, w.number, w.season_number, w.race_name, rr.*
from race_results rr
join races r on rr.race_id = r.id
join weeks w on r.week_id = w.id
join seasons s on w.season_id = s.id
where rr.best_position is null;

-- Handful of rows that are not special events with incomplete data (2012 week 23 Pure Michigan 400, 2017 32 Hollywood Casino 400, 2024 40 Xfinity 500)
select s.year, w.number, w.season_number, w.race_name, rr.*
from race_results rr
join races r on rr.race_id = r.id
join weeks w on r.week_id = w.id
join seasons s on w.season_id = s.id
where rr.best_position is null;

select s.year, w.number, w.season_number, w.race_name, rr.*
from race_results rr
join races r on rr.race_id = r.id
join weeks w on r.week_id = w.id
join seasons s on w.season_id = s.id
join cars_drivers cd on rr.car_driver_id = cd.id
join cars c on cd.car_id = c.id
join manufacturers m on c.manufacturer_id = m.id
where m.name = 'None';

select s.year, w.number, w.season_number, w.race_name, pr.*
from practice_results pr
join practices p on pr.practice_id = p.id
join weeks w on p.week_id = w.id
join seasons s on w.season_id = s.id
join cars_drivers cd on pr.car_driver_id = cd.id
join cars c on cd.car_id = c.id
join manufacturers m on c.manufacturer_id = m.id
where m.name = 'None';

select s.year, w.number, w.season_number, w.race_name, qr.*
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
join seasons s on w.season_id = s.id
join cars_drivers cd on qr.car_driver_id = cd.id
join cars c on cd.car_id = c.id
join manufacturers m on c.manufacturer_id = m.id
where m.name = 'None';

-- Cars where manufacturer is 'None'
select c.*
from cars_drivers cd
join cars c on cd.car_id = c.id
join manufacturers m on c.manufacturer_id = m.id
where m.name = 'None';

-- Handful of rows that represent the same driver (A.J. Allmendinger vs AJ Allmendinger, Geoff Bodine vs Geoffry Bodine, Jason White vs Jason A White, John H. Nemechek vs John Hunter Nemechek, Ray Black II vs Ray Black Jr, Will Kimmel vs Will Kimmel III
-- should just be able to update the cars_drivers table with the id of the record that is preferred, and then update the data_sources_drivers table for the names to the same driver_id
select *
from drivers d
order by d.first_name, d.last_name, d.suffix
;

-- Handful of rows that represent the same team (HIllman Racing vs Hillman Smith Motorsports, Kaluig Racing vs Kaulig Racing, Motorsports Bus Mgmnt vs Motorsports Business Management vs Motorsports Business Mgt, NY Racing vs NY Racing Team, rackhouse Racing vs Trackhouse Racing, Robert Richardson vs Robert Richardson Sr)
select *
from teams t
order by t.name
;

-- Some rows for some weeks in earlier years that have missing data
select s.year, w.number, w.season_number, w.race_name, qr.*
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
join seasons s on w.season_id = s.id
where best_speed is null or best_time is null or finish_position is null
;

-- no bad practice data
select s.year, w.number, w.season_number, w.race_name, pr.*
from practice_results pr
join practices p on pr.practice_id = p.id
join weeks w on p.week_id = w.id
join seasons s on w.season_id = s.id
where best_speed is null or best_time is null or finish_position is null
;

-- Bad parsing, or incomplete data for qualifyings
select s.year, w.number, w.race_name, qr.*
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
join seasons s on w.season_id = s.id
where qr.best_speed = 0 or qr.best_time = '00:00:00.000' or qr.best_speed is null or qr.best_time is null
order by s.year, w.number, w.race_name, qr.id
;

-- Bad parsing, or incomplete data for practices if (mph is present you can figure out time or vice versa
select s.year, w.number, w.race_name, pr.*
from practice_results pr
join practices p on pr.practice_id = p.id
join weeks w on p.week_id = w.id
join seasons s on w.season_id = s.id
where pr.best_speed = 0 or pr.best_time = '00:00:00.000' or pr.best_speed is null or pr.best_time is null
order by s.year, w.number, w.race_name, pr.id
;

-- Road Couse races time parsing is off. The hours should be 00 and looks like minutes are in place of the hours.
with track_median as (
    select w.track_id, median(best_speed) over (partition by w.track_id) as median_best_speed
	from qualifying_results qr
    join qualifyings q on qr.qualifying_id = q.id
	join weeks w on q.week_id = w.id
    group by w.track_id
)
select s.year, w.number, w.race_name, qr.id, tm.median_best_speed, qr.best_speed
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
join seasons s on w.season_id = s.id
join track_median tm on w.track_id = tm.track_id
join tracks t on w.track_id = t.id
order by s.year, w.number, w.race_name, qr.id
;

select *
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
where track_id = 36
order by qualifying_id, finish_position, best_time, best_speed desc;

select t.name as track_name, w.track_id, qr.best_speed
from qualifying_results qr
join qualifyings q on qr.qualifying_id = q.id
join weeks w on q.week_id = w.id
join seasons s on w.season_id = s.id
join tracks t on w.track_id = t.id
where 
group by 1, 2
order by 1, 2;

select *
from tracks;

update tracks
set name = 'Daytona International Speedway',
	length = 2.5
where id = 1
;

alter table tracks
	