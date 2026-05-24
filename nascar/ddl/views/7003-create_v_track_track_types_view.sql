-- season_manufacturer_race_results_overview: view used by NASCAR analytics workflows.
-- Provide/maintain business context using fantasy-sports-airflow DAG and SQL usage when editing this object.

DROP VIEW IF EXISTS `v_tracks_track_types`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_tracks_track_types` AS
select
    t.id as track_id,
    t.name as track_name,
    group_concat(tt.name) as track_types
from nascar.tracks t
join nascar.tracks_track_types ttt on ttt.track_id = t.id and ttt.deleted_at is null
join nascar.track_types tt on tt.id = ttt.track_type_id and tt.deleted_at is null
where t.deleted_at is null
group by t.id
;
