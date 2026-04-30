DELIMITER //

DROP TRIGGER IF EXISTS `nascar`.`trg_series_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_series_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`series`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`seasons` SET `deleted_at` = NEW.`deleted_at` WHERE `series_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `series_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`seasons` SET `deleted_at` = NULL WHERE `series_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `series_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_seasons_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_seasons_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`seasons`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NEW.`deleted_at` WHERE `season_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `season_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NULL WHERE `season_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `season_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_weeks_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_weeks_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`weeks`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`races` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`practices` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`qualifyings` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `week_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`races` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`practices` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`qualifyings` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `week_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_races_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_races_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`races`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NEW.`deleted_at` WHERE `race_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NEW.`deleted_at` WHERE `race_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NEW.`deleted_at` WHERE `race_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NEW.`deleted_at` WHERE `race_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `race_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NULL WHERE `race_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NULL WHERE `race_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NULL WHERE `race_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NULL WHERE `race_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `race_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_practices_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_practices_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`practices`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NEW.`deleted_at` WHERE `practice_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NULL WHERE `practice_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_qualifyings_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_qualifyings_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`qualifyings`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NEW.`deleted_at` WHERE `qualifying_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NULL WHERE `qualifying_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_manufacturers_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_manufacturers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`manufacturers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `manufacturer_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_teams_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_teams_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`teams`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NEW.`deleted_at` WHERE `team_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `team_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars` SET `deleted_at` = NULL WHERE `team_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `team_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_drivers_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_drivers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`drivers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NEW.`deleted_at` WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NULL WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_cars_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_cars_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`cars`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NEW.`deleted_at` WHERE `car_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`cars_drivers` SET `deleted_at` = NULL WHERE `car_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `car_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_cars_drivers_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_cars_drivers_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`cars_drivers`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`race_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`practice_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`qualifying_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`penalties` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`pitstops` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `car_driver_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_tracks_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_tracks_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`tracks`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NEW.`deleted_at` WHERE `track_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`weeks` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`week_results` SET `deleted_at` = NULL WHERE `track_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_track_types_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_track_types_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`track_types`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NEW.`deleted_at` WHERE `track_type_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`tracks_track_types` SET `deleted_at` = NULL WHERE `track_type_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_data_sources_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_data_sources_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`data_sources`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`data_sources_drivers` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_teams` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_manufacturers` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`data_sources_tracks` SET `deleted_at` = NEW.`deleted_at` WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`data_sources_drivers` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_teams` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_manufacturers` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`data_sources_tracks` SET `deleted_at` = NULL WHERE `data_source_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DROP TRIGGER IF EXISTS `nascar`.`trg_dfs_soft_delete_cascade` //
CREATE TRIGGER `nascar`.`trg_dfs_soft_delete_cascade`
AFTER UPDATE ON `nascar`.`dfs`
FOR EACH ROW
BEGIN
    IF OLD.`deleted_at` IS NULL AND NEW.`deleted_at` IS NOT NULL THEN
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NEW.`deleted_at` WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NULL;
        UPDATE `nascar`.`dfs_scoring_rules` SET `deleted_at` = NEW.`deleted_at` WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NULL;
    ELSEIF OLD.`deleted_at` IS NOT NULL AND NEW.`deleted_at` IS NULL THEN
        UPDATE `nascar`.`dfs_salaries` SET `deleted_at` = NULL WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
        UPDATE `nascar`.`dfs_scoring_rules` SET `deleted_at` = NULL WHERE `dfs_id` = NEW.`id` AND `deleted_at` IS NOT NULL;
    END IF;
END //

DELIMITER ;
