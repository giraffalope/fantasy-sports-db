ALTER TABLE `dfs_race_lineups` ADD CONSTRAINT `fk_dfs_race_lineups_dfs_id` FOREIGN KEY (`dfs_id`) REFERENCES `dfs` (`id`) ON DELETE CASCADE;
