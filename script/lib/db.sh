# Shared MariaDB helpers for script/query and script/migrate.
# shellcheck shell=sh

db_load_env() {
    BASEDIR="$(cd "$(dirname "$0")/../.." && pwd)"
    if [ -f "$BASEDIR/.env" ]; then
        set -a
        # shellcheck disable=SC1091
        . "$BASEDIR/.env"
        set +a
    fi
    DB_CONTAINER_NAME="${DB_CONTAINER_NAME:-fantasy-sports-db}"
    DB_NAME="${DB_NAME:-nascar}"
    DB_USER="${DB_USER:-username}"
    DB_PASSWORD="${DB_PASSWORD:-password}"
    DATABASE_PORT="${DATABASE_PORT:-36000}"
}

db_mariadb_base() {
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$DB_NAME"
}

db_require_container() {
    if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER_NAME"; then
        echo "Container '$DB_CONTAINER_NAME' is not running. Start it with ./script/server" >&2
        exit 1
    fi
}

db_exec_file() {
    db_mariadb_base <"$1"
}

db_exec_sql() {
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$DB_NAME" \
        -e "$1"
}

db_query_scalar() {
    _sql="$1"
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -N \
        -s \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$DB_NAME" \
        -e "$_sql" 2>/dev/null | tr -d '\r'
}

db_query_file() {
    db_mariadb_base <"$1"
}

db_query_sql() {
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -t \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$DB_NAME" \
        -e "$1"
}

db_query_stdin() {
    db_mariadb_base
}

db_exec_file_with_options() {
    _file="$1"
    shift
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$@" \
        "$DB_NAME" <"$_file"
}

db_exec_stream_with_options() {
    docker exec -i "$DB_CONTAINER_NAME" mariadb \
        -u"$DB_USER" \
        -p"$DB_PASSWORD" \
        "$@" \
        "$DB_NAME"
}

db_ensure_schema_migrations_table() {
    db_exec_sql "CREATE TABLE IF NOT EXISTS nascar.schema_migrations (
  id bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  filename varchar(255) NOT NULL,
  checksum char(64) DEFAULT NULL,
  applied_at timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (id),
  UNIQUE KEY unique_schema_migrations_filename (filename)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;"
}

db_migration_checksum() {
    sha256sum "$1" | awk '{print $1}'
}

db_migration_is_applied() {
    _filename="$1"
    _count="$(db_query_scalar "SELECT COUNT(*) FROM nascar.schema_migrations WHERE filename = '${_filename//\'/\\\'}'")"
    [ "${_count:-0}" -gt 0 ]
}

db_migration_record_applied() {
    _filename="$1"
    _checksum="$2"
    _escaped_filename="${_filename//\'/\'\'}"
    _escaped_checksum="${_checksum//\'/\'\'}"
    db_exec_sql "INSERT INTO nascar.schema_migrations (filename, checksum) VALUES ('${_escaped_filename}', '${_escaped_checksum}');"
}
