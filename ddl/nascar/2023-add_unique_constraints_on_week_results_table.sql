ALTER TABLE `nascar`.`week_results`
  ADD UNIQUE KEY `unique_week_results_series_season_week_race_car_driver` (
    `series_id`,
    `season_id`,
    `week_id`,
    `race_id`,
    `car_driver_id`
  );
