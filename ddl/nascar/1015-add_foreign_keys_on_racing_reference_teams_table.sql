ALTER TABLE `nascar`.`racing_reference_teams`
    ADD CONSTRAINT `fk_teams_racing_reference_teams_team_id` FOREIGN KEY (`team_id`) REFERENCES `nascar`.`teams` (`id`) ON DELETE CASCADE;
