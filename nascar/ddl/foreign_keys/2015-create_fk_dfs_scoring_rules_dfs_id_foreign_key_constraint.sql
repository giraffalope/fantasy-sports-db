ALTER TABLE `dfs_scoring_rules` ADD CONSTRAINT `fk_dfs_scoring_rules_dfs_id` FOREIGN KEY (`dfs_id`) REFERENCES `dfs` (`id`) ON DELETE CASCADE;
