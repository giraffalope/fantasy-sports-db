# NASCAR seed data

MariaDB runs these files from `/docker-entrypoint-initdb.d/` **after** all `nascar/ddl/` scripts (lexical order by numeric prefix).

| File | Purpose |
|------|---------|
| `9000-load_nascar_database_snapshot.sql.gz` | Full `nascar` data dump (INSERT-only). Primary bootstrap dataset. |
| `9001-insert_dfs_seed.sql` | Idempotent DraftKings `dfs` row (`id = 1`). |
| `9002-insert_dfs_scoring_rules_seed.sql` | Idempotent DraftKings Cup rules (`cup_default`). |

The snapshot is large (~600MB compressed) and is not committed to git. Copy or sync it before `./script/build`:

```bash
./script/sync-seed-snapshot
```

Default source: `../fantasy-sports-airflow/db/backups/20260525T031712Z.sql.gz`.

Seeds are not migrations: forward schema changes on live DBs belong in `nascar/migrations/` and `./script/migrate`.
