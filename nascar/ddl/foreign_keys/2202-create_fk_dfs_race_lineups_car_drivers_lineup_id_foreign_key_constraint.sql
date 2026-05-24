ALTER TABLE `dfs_race_lineups_car_drivers` ADD CONSTRAINT `fk_dfs_race_lineups_car_drivers_lineup_id` FOREIGN KEY (`dfs_race_lineup_id`) REFERENCES `dfs_race_lineups` (`id`) ON DELETE CASCADE;
