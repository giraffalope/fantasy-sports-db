# AGENTS.md

Read and follow [CONTRIBUTING.md](CONTRIBUTING.md) for schema, seed, migration, and SQL conventions.

## Where to put SQL

| Location | Use when |
|----------|----------|
| `nascar/ddl/` | Canonical schema for **fresh** Docker init (tables, FKs, views, procs, …) |
| `nascar/seed/` | Bootstrap data after DDL (snapshot `9000`, small idempotent `9001`/`9002`) |
| `nascar/migrations/` | Forward changes on **existing** DBs; apply with `./script/migrate` (ledger) |
| `nascar/queries/` | Ad-hoc / investigative SQL; run with `./script/query` (no ledger) |
| `nascar/scripts/` | Operational one-off repairs; also via `./script/query` |

## Schema change checklist

1. **DDL** — add or update files under the correct `nascar/ddl/{tables,foreign_keys,...}` band.
2. **Migration** — if live DBs need the change, add `nascar/migrations/YYYYMMDDTHHMMSS_description.sql` and run `./script/migrate <file>`.
3. **Seed** — only when reference data is required (`nascar/seed/9XXX-…`).
4. **Verify fresh init** — `./script/clear-db && ./script/build && ./script/server` (new volume).
5. **Verify live** — `./script/migrate …` against a running container.
6. **Downstream** — update `fantasy-sports-airflow` importers/SQL contracts if the object is used there.

Do not copy `nascar/migrations/` into the Docker image init path. Migrations are not auto-run on init.

## Scripts

- `./script/query` — run SQL (file, argument, or stdin); sets `pager less -SFX` before your SQL.
- `./script/migrate` — apply one migration file; records basename in `nascar.schema_migrations`; refuses duplicates.

Server must be running (`./script/server`). Default host port: **36000** (`DATABASE_PORT` in `.env`).
