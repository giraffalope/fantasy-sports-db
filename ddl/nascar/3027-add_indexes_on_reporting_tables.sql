ALTER TABLE `nascar`.`week_results`
  ADD INDEX `idx_week_results_week_driver` (`week_id`, `driver_id`),
  ADD INDEX `idx_week_results_season_week` (`season_id`, `week_id`);

ALTER TABLE `nascar`.`hist_weeks_track_types`
  ADD INDEX `idx_hist_weeks_track_types_track_type_season_week` (`track_type_id`, `season_id`, `week_id`);
