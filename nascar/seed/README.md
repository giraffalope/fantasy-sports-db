# NASCAR seed data

MariaDB runs these files from `/docker-entrypoint-initdb.d/` **after** all `nascar/ddl/` scripts (lexical order by numeric prefix).

| File | Purpose |
|------|---------|
| `9000-load_nascar_database_snapshot.sql.gz` | Full `nascar` data dump (INSERT-only). Primary bootstrap dataset. |
| `9001-insert_dfs_seed.sql` | Idempotent DraftKings `dfs` row (`id = 1`). |
| `9002-insert_dfs_scoring_rules_seed.sql` | Idempotent DraftKings Cup rules (`cup_default`). |

The snapshot is large (~600MB compressed) and is not committed to git. Refresh it before `./script/build`:

**Preferred** — dump from the Airflow stack and install as seed 9000:

```bash
cd ../fantasy-sports-airflow
./script/db-backup --sync
```

**Or** copy an existing backup file:

```bash
./script/sync-seed-snapshot
./script/sync-seed-snapshot /path/to/backup.sql.gz
```

Default source for `sync-seed-snapshot`: `../fantasy-sports-airflow/db/backups/20260525T031712Z.sql.gz`.

Seeds are not migrations: forward schema changes on live DBs belong in `nascar/migrations/` and `./script/migrate`.
