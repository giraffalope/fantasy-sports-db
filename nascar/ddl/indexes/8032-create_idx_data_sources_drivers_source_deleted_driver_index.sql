ALTER TABLE `data_sources_drivers` ADD KEY `idx_data_sources_drivers_source_deleted_driver` (`data_source_id`,`deleted_at`,`driver_id`);
