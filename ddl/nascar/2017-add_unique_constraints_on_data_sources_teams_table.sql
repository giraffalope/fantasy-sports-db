ALTER TABLE `nascar`.`data_sources_teams`
  ADD UNIQUE KEY `unique_data_sources_teams_source_name` (`data_source_id`, `name`);
