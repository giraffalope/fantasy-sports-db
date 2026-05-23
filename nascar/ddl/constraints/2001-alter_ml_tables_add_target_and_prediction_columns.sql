-- ML component-target columns: predict scoring-rule source stats, derive dfs_points.

ALTER TABLE `ml_training_snapshots`
    ADD COLUMN `target_keys` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Ordered JSON array of label stat columns the model predicts.' CHECK (`target_keys` IS NULL OR json_valid(`target_keys`)),
    ADD COLUMN `target_column_count` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Number of keys in target_keys.',
    ADD COLUMN `target_schema_hash` char(64) DEFAULT NULL COMMENT 'SHA-256 hex of canonical target_keys JSON.';

ALTER TABLE `ml_labels`
    ADD COLUMN `targets_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Ground-truth post-race stats keyed by scoring-rule source fields.' CHECK (`targets_json` IS NULL OR json_valid(`targets_json`));

ALTER TABLE `ml_predictions`
    ADD COLUMN `predicted_targets_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Model-predicted stats keyed like target_keys.' CHECK (`predicted_targets_json` IS NULL OR json_valid(`predicted_targets_json`)),
    ADD COLUMN `predicted_dfs_points_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Component points from scoring rules on predicted stats.' CHECK (`predicted_dfs_points_breakdown` IS NULL OR json_valid(`predicted_dfs_points_breakdown`));

ALTER TABLE `ml_feature_sets`
    ADD COLUMN `target_keys` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Label stat columns used when training this feature set.' CHECK (`target_keys` IS NULL OR json_valid(`target_keys`));
