ALTER TABLE `ml_training_snapshots` ADD CONSTRAINT `fk_ml_training_snapshots_dfs_scoring_rules_id` FOREIGN KEY (`dfs_scoring_rules_id`) REFERENCES `dfs_scoring_rules` (`id`) ON DELETE CASCADE;
