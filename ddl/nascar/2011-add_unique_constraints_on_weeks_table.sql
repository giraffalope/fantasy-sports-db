ALTER TABLE `nascar`.`weeks`
  ADD UNIQUE KEY `unique_weeks_season_track_number_season_number` (`season_id`, `track_id`, `number`, `season_number`);
  