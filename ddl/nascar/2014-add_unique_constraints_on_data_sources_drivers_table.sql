ALTER TABLE `nascar`.`data_sources_drivers`
  ADD UNIQUE KEY `unique_data_sources_drivers_source_name` (`data_source_id`, `name`);
  