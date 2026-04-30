ALTER TABLE `dfs_salaries` ADD CONSTRAINT `fk_dfs_salaries_dfs_id` FOREIGN KEY (`dfs_id`) REFERENCES `dfs` (`id`) ON DELETE CASCADE;
