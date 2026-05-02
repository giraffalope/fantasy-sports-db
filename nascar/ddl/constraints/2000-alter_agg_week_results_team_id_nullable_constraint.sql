ALTER TABLE `agg_week_results`
MODIFY `team_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Foreign key to nascar.teams, indicating the team for which this week''s statistics apply.';
