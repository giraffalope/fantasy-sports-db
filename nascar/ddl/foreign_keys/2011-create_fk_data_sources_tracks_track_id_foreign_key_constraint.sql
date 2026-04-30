ALTER TABLE `data_sources_tracks` ADD CONSTRAINT `fk_data_sources_tracks_track_id` FOREIGN KEY (`track_id`) REFERENCES `tracks` (`id`) ON DELETE CASCADE;
