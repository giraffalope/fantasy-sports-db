ALTER TABLE `nascar`.`data_sources_tracks`
  ADD UNIQUE KEY `unique_data_sources_tracks_source_name` (`data_source_id`, `name`);
