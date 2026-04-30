ALTER TABLE `dfs_salaries` ADD CONSTRAINT `fk_dfs_salaries_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
