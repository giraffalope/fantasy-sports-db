ALTER TABLE `nascar`.`racing_reference_tracks`
    ADD CONSTRAINT `fk_tracks_racing_reference_tracks_track_id` FOREIGN KEY (`track_id`) REFERENCES `nascar`.`tracks` (`id`) ON DELETE CASCADE;
