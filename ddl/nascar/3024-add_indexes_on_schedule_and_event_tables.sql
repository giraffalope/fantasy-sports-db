ALTER TABLE `nascar`.`weeks`
  ADD INDEX `idx_weeks_season_number_season_number` (`season_id`, `number`, `season_number`);

ALTER TABLE `nascar`.`races`
  ADD INDEX `idx_races_week_deleted_at` (`week_id`, `deleted_at`);

ALTER TABLE `nascar`.`practices`
  ADD INDEX `idx_practices_week_number_deleted_at` (`week_id`, `number`, `deleted_at`);

ALTER TABLE `nascar`.`qualifyings`
  ADD INDEX `idx_qualifyings_week_deleted_at` (`week_id`, `deleted_at`);
