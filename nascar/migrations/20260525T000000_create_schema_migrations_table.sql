-- Bootstrap ledger for ./script/migrate on databases created before DDL 1099.
CREATE TABLE IF NOT EXISTS nascar.schema_migrations (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Surrogate primary key.',
  `filename` varchar(255) NOT NULL COMMENT 'Basename of applied migration file under nascar/migrations/.',
  `checksum` char(64) DEFAULT NULL COMMENT 'SHA-256 hex digest of migration file contents at apply time.',
  `applied_at` timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'When the migration was recorded.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_schema_migrations_filename` (`filename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci COMMENT='Ledger of applied forward migrations for existing databases.';
