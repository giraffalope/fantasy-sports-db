ALTER TABLE `dfs_race_lineups` ADD CONSTRAINT `fk_dfs_race_lineups_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
