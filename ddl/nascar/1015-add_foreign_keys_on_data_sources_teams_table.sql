ALTER TABLE `nascar`.`data_sources_teams`
    ADD CONSTRAINT `fk_data_sources_teams_data_source_id` FOREIGN KEY (`data_source_id`) REFERENCES `nascar`.`data_sources` (`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_data_sources_teams_team_id` FOREIGN KEY (`team_id`) REFERENCES `nascar`.`teams` (`id`) ON DELETE CASCADE;
