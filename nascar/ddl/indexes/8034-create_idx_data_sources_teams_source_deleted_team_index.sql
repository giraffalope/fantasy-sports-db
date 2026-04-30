ALTER TABLE `data_sources_teams` ADD KEY `idx_data_sources_teams_source_deleted_team` (`data_source_id`,`deleted_at`,`team_id`);
