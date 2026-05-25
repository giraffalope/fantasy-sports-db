ALTER TABLE `dfs_strategies_race_lineups` ADD CONSTRAINT `fk_dfs_strategies_race_lineups_dfs_strategy_id` FOREIGN KEY (`dfs_strategy_id`) REFERENCES `dfs_strategies` (`id`) ON DELETE CASCADE;
