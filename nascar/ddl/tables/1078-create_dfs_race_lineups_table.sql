CREATE TABLE `dfs_race_lineups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `dfs_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to DFS provider.',
  `race_id` bigint(20) unsigned NOT NULL COMMENT 'Foreign key to race.',
  `projected_points_total` decimal(14,2) unsigned NOT NULL COMMENT 'Sum of projected DFS points for lineup drivers.',
  `salary_total` int(10) unsigned NOT NULL COMMENT 'Sum of DraftKings salaries for lineup drivers.',
  `mc_mean_dfs_points` decimal(14,3) DEFAULT NULL COMMENT 'Lineup mean DFS points across joint MC draws (rank-coupling preserved; equals sum-of-driver-means within rounding when samples are independent).',
  `mc_std_dfs_points` decimal(14,3) DEFAULT NULL COMMENT 'Lineup std DFS points across joint MC draws; under E2 rank-coupling this is < sqrt(sum(driver_std^2)) because anti-correlated finishes attenuate cohort variance.',
  `mc_p10_dfs_points` decimal(14,3) DEFAULT NULL COMMENT 'Lineup 10th-percentile DFS points (high-floor metric used as the DOUBLE_UP cash-game objective).',
  `mc_p50_dfs_points` decimal(14,3) DEFAULT NULL COMMENT 'Lineup median DFS points across joint MC draws (audit / leaderboard).',
  `mc_p90_dfs_points` decimal(14,3) DEFAULT NULL COMMENT 'Lineup 90th-percentile DFS points (high-ceiling metric used as the HIGH_RISK_REWARD GPP objective).',
  `mc_sharpe` decimal(10,4) DEFAULT NULL COMMENT 'mc_mean_dfs_points / max(mc_std_dfs_points, 1e-6); higher means more certainty per unit of expected return.',
  `objective_value` decimal(14,3) DEFAULT NULL COMMENT 'The actual scalar the portfolio selector maximized for this row (varies by strategy: joint_p10 for DOUBLE_UP, joint_p90 for HIGH_RISK_REWARD, etc.).',
  `mc_score_method` varchar(32) DEFAULT NULL COMMENT 'Audit trail of how mc_* columns were computed: joint_p10 / joint_p50 / joint_p90 / joint_mean / joint_sharpe / summary_fallback (independent Gaussian from driver summaries when the joint .npz artifact is missing).',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Creation timestamp.',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp.',
  `deleted_at` timestamp NULL DEFAULT NULL COMMENT 'Soft-delete timestamp; NULL means active.',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='DFS race lineups generated from ML projections and salaries.';
