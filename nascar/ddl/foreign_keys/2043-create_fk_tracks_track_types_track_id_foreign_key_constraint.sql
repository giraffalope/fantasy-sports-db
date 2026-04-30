ALTER TABLE `tracks_track_types` ADD CONSTRAINT `fk_tracks_track_types_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
