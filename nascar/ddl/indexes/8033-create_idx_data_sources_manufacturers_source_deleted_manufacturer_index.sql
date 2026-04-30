ALTER TABLE `data_sources_manufacturers` ADD KEY `idx_data_sources_manufacturers_source_deleted_manufacturer` (`data_source_id`,`deleted_at`,`manufacturer_id`);
