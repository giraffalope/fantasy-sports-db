ALTER TABLE `ml_training_snapshots` ADD CONSTRAINT `fk_ml_training_snapshots_dfs_id` FOREIGN KEY (`dfs_id`) REFERENCES `dfs` (`id`) ON DELETE CASCADE;
