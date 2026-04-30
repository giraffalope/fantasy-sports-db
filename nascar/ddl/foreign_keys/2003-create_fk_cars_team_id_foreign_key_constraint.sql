ALTER TABLE `cars` ADD CONSTRAINT `fk_cars_team_id` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE;
