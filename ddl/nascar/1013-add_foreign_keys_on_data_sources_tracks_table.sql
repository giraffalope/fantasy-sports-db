ALTER TABLE `nascar`.`data_sources_tracks`
    ADD CONSTRAINT `fk_data_sources_tracks_data_source_id` FOREIGN KEY (`data_source_id`) REFERENCES `nascar`.`data_sources` (`id`) ON DELETE CASCADE,
    ADD CONSTRAINT `fk_data_sources_tracks_track_id` FOREIGN KEY (`track_id`) REFERENCES `nascar`.`tracks` (`id`) ON DELETE CASCADE;
