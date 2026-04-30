ALTER TABLE `pitstops` ADD CONSTRAINT `fk_pitstops_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
