# Contributing

## Scope
- This repository manages the fantasy sports database schema and initialization SQL.
- For NASCAR assets, use the canonical structure:
  - `nascar/ddl`
  - `nascar/seed`
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

### Seed Naming (`nascar/seed`)
- Seed files: `XXXX-insert_{tablename}_seed.sql`
- Keep one seed file per table (merge inserts for the same table into one file).

## Execution Contract
- Container/database initialization must run all DDL files first (across `nascar/ddl` subfolders), then all seed files.
- `nascar/queries` is for non-bootstrap SQL files only and must not be auto-executed by init entrypoints.

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
