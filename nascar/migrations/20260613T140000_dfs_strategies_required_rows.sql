-- Backfill the required `dfs_strategies` rows (`DOUBLE_UP`, `HIGH_RISK_REWARD`)
-- for environments that initialized from the DDL+seed bootstrap before seed
-- `9003-insert_dfs_strategies_seed.sql` was added. Mirrors the inserts in
-- migration 20260525180000_dfs_strategies_and_race_lineups_pivot.sql so
-- environments that never applied that pivot migration (because they came
-- up from a snapshot taken before it landed) get the strategy rows the
-- lineup generator DAG requires.
--
-- Idempotent: relies on `unique_dfs_strategies_name` and revives any
-- soft-deleted row with the same name. Safe to apply repeatedly through
-- ./script/migrate (or ./script/db-migrate from fantasy-sports-airflow).

INSERT INTO nascar.dfs_strategies (name)
VALUES ('DOUBLE_UP')
ON DUPLICATE KEY UPDATE
    deleted_at = NULL;

INSERT INTO nascar.dfs_strategies (name)
VALUES ('HIGH_RISK_REWARD')
ON DUPLICATE KEY UPDATE
    deleted_at = NULL;
