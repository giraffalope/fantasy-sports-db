# NASCAR migrations

Forward-only SQL for **existing** databases. Not executed during Docker init (see `nascar/ddl/` and `nascar/seed/`).

## Naming

`YYYYMMDDTHHMMSS_short_description.sql`

Example: `20260525T120000_add_car_generation_models_seasons_index.sql`

## Apply

```bash
./script/migrate nascar/migrations/20260525T120000_add_foo.sql
```

`script/migrate` records the file basename in `nascar.schema_migrations` and refuses to run the same file twice.

## Authoring rules

- One logical change per file; prefer idempotent SQL (`IF NOT EXISTS`, etc.).
- After shipping a migration, mirror the schema change in canonical `nascar/ddl/` so fresh installs stay equivalent.
- Ad-hoc or investigative SQL belongs in `nascar/queries/` and runs via `./script/query` (no ledger).

## Bootstrap

`20260525T000000_create_schema_migrations_table.sql` creates the ledger on databases that predate DDL `1099-create_schema_migrations_table.sql`.
