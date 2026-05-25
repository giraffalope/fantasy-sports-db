# Contributing

## Scope
- This repository manages the fantasy sports database schema and initialization SQL.
- For NASCAR assets, use the canonical structure:
  - `nascar/ddl`
  - `nascar/seed`
  - `nascar/migrations`
  - `nascar/queries`
  - DDL subfolders by object type:
    - `nascar/ddl/tables`
    - `nascar/ddl/foreign_keys`
    - `nascar/ddl/unique_keys`
    - `nascar/ddl/triggers`
    - `nascar/ddl/functions`
    - `nascar/ddl/stored_procedures`
    - `nascar/ddl/views`
    - `nascar/ddl/indexes`
    - `nascar/ddl/constraints`

## Required SQL File Formatting
- Keep one logical object per file whenever possible.
- Use lowercase snake_case object names in filenames.
- Use numeric prefixes for deterministic lexical execution order.

### DDL Naming Bands (`nascar/ddl`)
- Tables: `1XXX-create_{tablename}_table.sql`
- Foreign keys: `2XXX-create_{foreignkey}_foreign_key_constraint.sql`
- Unique keys: `3XXX-create_{uniquekeyname}_unique_key_constraint.sql`
- Triggers: `4XXX-create_{triggername}_trigger.sql`
- Functions: `5XXX-create_{functionname}_function.sql`
- Stored procedures: `6XXX-create_{storedprocedurename}_stored_procedure.sql`
- Views: `7XXX-create_{viewname}_view.sql`

### Migration Naming (`nascar/migrations`)
- Migration files: `YYYYMMDDTHHMMSS_short_description.sql` (one logical change per file).
- Apply with `./script/migrate path/to/file.sql`; basename is stored in `nascar.schema_migrations`.
- Not copied into Docker init; for existing databases only.
- After shipping a migration, mirror the schema change into canonical `nascar/ddl/` so fresh installs stay equivalent.
- Prefer idempotent SQL (`IF NOT EXISTS`, etc.).

### Seed Naming (`nascar/seed`)
- Table seed files: `XXXX-insert_{tablename}_seed.sql` (one file per table; merge inserts for the same table into one file).
- Full-database snapshot: `9000-load_nascar_database_snapshot.sql.gz` (MariaDB executes `.sql.gz` in init; data-only dump after DDL).
- Sync the snapshot before image build: `./script/sync-seed-snapshot` (see `nascar/seed/README.md`).

## Execution Contract
- Container/database initialization must run all DDL files first (across `nascar/ddl` subfolders), then all seed files.
- `nascar/migrations` must not be auto-executed by init entrypoints; use `./script/migrate` on running databases.
- `nascar/queries` is for non-bootstrap SQL files only and must not be auto-executed by init entrypoints.

## Query and migrate scripts
- `./script/query` — stateless SQL runner (file `-f`, inline argument, or stdin). Sets `pager less -SFX` before user SQL.
- `./script/migrate` — runs one migration file in batch mode (no pager), then inserts into `nascar.schema_migrations`.
- Requires container `fantasy-sports-db` from `./script/server` (see `.env` for `DB_*` and `DATABASE_PORT`).

## Schema changes (existing database)
1. Add idempotent migration under `nascar/migrations/`.
2. `./script/migrate nascar/migrations/….sql`.
3. Update matching `nascar/ddl/` files for fresh-init parity.
4. Rebuild/verify: `./script/build` and fresh volume init when DDL changed.

## Schema changes (new objects on fresh install)
1. Add DDL in the correct `nascar/ddl/` bands (see checklist below).
2. Add seeds only if needed (`9XXX`).
3. Add a migration only when live DBs already exist and cannot be rebuilt from DDL alone.

## Authoring Guidelines
- Keep migrations deterministic and idempotent where practical.
- Prefer explicit constraint names (FK/unique/index/trigger names must be stable).
- Ensure new files preserve dependency order (tables before constraints, routines before dependent views/triggers).
- When refactoring, avoid mixing schema creation and data seeding in the same file.
- Do not place metadata artifacts (TSV dumps, manifests, snapshots) in `nascar/queries`; keep only `.sql` query files there.

## Commenting Requirements
- Provide descriptive comments for all new or changed database objects:
  - tables
  - columns
  - views
  - functions
  - stored procedures
- For tables and columns, use native SQL comments (`COMMENT` clauses) where supported.
- For views/functions/stored procedures, include clear SQL comments in the file describing purpose, inputs, outputs, and business intent.
- Prefer domain-aware comments over generic descriptions. Use context from `fantasy-sports-airflow` (DAGs, SQL loaders, importers, and downstream usage) to write accurate comments for fields and transformations.
- When object meaning is inferred from usage in `fantasy-sports-airflow`, document that intent directly in the comment so future maintainers can trace why the schema element exists.

## Checklist: adding a new table (`nascar/ddl`)

1. **Table DDL** in `nascar/ddl/tables` with a new `1XXX` prefix that preserves dependency order (referenced tables must exist first).
2. **Foreign keys** in `nascar/ddl/foreign_keys` (`2XXX`): one file per constraint, `ON DELETE` semantics aligned with how orphan rows should behave.
3. **Indexes** in `nascar/ddl/indexes` (`8XXX`) for lookup paths and any FK columns that need explicit secondary indexes for query plans (follow existing patterns in the repo).
4. **Unique keys** in `nascar/ddl/unique_keys` (`3XXX`) for natural or composite business keys where duplicates must be rejected.
5. **Triggers** in `nascar/ddl/triggers` (`4XXX`) for soft-delete cascade or other invariants; extend existing dimension triggers when new child or aggregate tables reference those dimensions.
6. **Views / stored procedures** (`7XXX` / `6XXX`) if any reporting or loaders reference the new grain; keep view definitions consistent with soft-delete filters elsewhere.
7. **Seeds** in `nascar/seed` (`9XXX`) when the table ships reference data; keep deterministic primary keys and idempotent `ON DUPLICATE KEY` updates where used.
8. **`nascar/ddl/constraints`** when live databases need a one-off guard (optional; not auto-modeled in all environments).
9. **Verification**: build or start the `fantasy-sports-db` Docker image so MariaDB runs all `docker-entrypoint-initdb.d` scripts; fix ordering or duplicate object-name failures until init is clean.

### NASCAR: `car_generation_model_id` and previous-track aggregates

`car_generation_models` is not keyed directly by `car_generation_id`. For **`agg_week_prev_track_*`** (and any other SQL) that must relate a **car generation model** to a **car generation** and **seasons**, join through **`car_generation_models_seasons`**: use `car_generation_models_seasons.car_generations_seasons_id` → **`car_generations_seasons`** (which carries `car_generation_id` and `season_id`) to enumerate all relevant seasons and generations for a given model bridge row. Do not assume `car_generation_model_id` alone implies `car_generation_id` without that bridge.
