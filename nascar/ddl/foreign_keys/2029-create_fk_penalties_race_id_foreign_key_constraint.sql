ALTER TABLE `penalties` ADD CONSTRAINT `fk_penalties_race_id` FOREIGN KEY (`race_id`) REFERENCES `races` (`id`) ON DELETE CASCADE;
