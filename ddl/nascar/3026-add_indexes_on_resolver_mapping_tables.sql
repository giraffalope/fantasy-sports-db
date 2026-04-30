ALTER TABLE `nascar`.`cars`
  ADD INDEX `idx_cars_number_team_manufacturer_deleted_at` (`number`, `team_id`, `manufacturer_id`, `deleted_at`);

ALTER TABLE `nascar`.`cars_drivers`
  ADD INDEX `idx_cars_drivers_driver_deleted_at` (`driver_id`, `deleted_at`);

ALTER TABLE `nascar`.`data_sources_drivers`
  ADD INDEX `idx_data_sources_drivers_source_deleted_driver` (`data_source_id`, `deleted_at`, `driver_id`);

ALTER TABLE `nascar`.`data_sources_teams`
  ADD INDEX `idx_data_sources_teams_source_deleted_team` (`data_source_id`, `deleted_at`, `team_id`);

ALTER TABLE `nascar`.`data_sources_manufacturers`
  ADD INDEX `idx_data_sources_manufacturers_source_deleted_manufacturer` (`data_source_id`, `deleted_at`, `manufacturer_id`);
