ALTER TABLE `dfs_strategies_race_lineups` ADD CONSTRAINT `fk_dfs_strategies_race_lineups_dfs_race_lineup_id` FOREIGN KEY (`dfs_race_lineup_id`) REFERENCES `dfs_race_lineups` (`id`) ON DELETE CASCADE;
