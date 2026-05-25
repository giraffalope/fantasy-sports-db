# Fantasy Sports DB
This repository contains the database schemas for all fantasy sports that are being tracked.

## Docker Image

### Building the Image

Build and tag the Docker image:

```bash
docker build -t fantasy-sports-db:latest .
```

Or with a specific version tag:

```bash
docker build -t fantasy-sports-db:v1.0 .
```

### Running the Container

Run the container with the initialized database:

```bash
docker run -d \
  --name fantasy-sports-db \
  -e MYSQL_ROOT_PASSWORD=your_secure_password \
  -e MYSQL_USER=dbuser \
  -e MYSQL_PASSWORD=your_secure_password \
  -e MYSQL_DATABASE=nascar \
  -p 3306:3306 \
  fantasy-sports-db:latest
```

**Security Note:** Sensitive credentials like `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` should NOT be hardcoded in the Dockerfile. Always provide them at runtime via environment variables, or better yet, use Docker secrets in production environments.

### Using in Docker Compose

Reference the image in `docker-compose.yml`:

```yaml
services:
  db:
    build: ./fantasy-sports-db
    # Or use a pre-built image:
    # image: fantasy-sports-db:latest
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_USER: ${DB_USER}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_DATABASE: nascar
    ports:
      - "3306:3306"
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

Create a `.env` file to provide credentials:

```env
DB_ROOT_PASSWORD=your_secure_root_password
DB_USER=nascar_user
DB_PASSWORD=your_secure_user_password
```

Then run:
```bash
docker compose up -d db
```

### Environment Variables

**Sensitive Variables (provide at runtime, not in Dockerfile):**

- `MYSQL_ROOT_PASSWORD`: Password for the MariaDB root user (required, set at runtime)
- `MYSQL_PASSWORD`: Password for the MYSQL_USER account (optional, set at runtime)

**Non-sensitive Variables (set in Dockerfile):**

- `MYSQL_DATABASE`: Database to create on initialization (default: nascar)
- `MYSQL_USER`: Username for non-root database user (optional, set at runtime)
- `MARIADB_AUTO_UPGRADE`: Automatically upgrade database schema (default: 1)

**Best Practices:**
- Never commit sensitive credentials to version control
- Use `.env` files locally (add to `.gitignore`)
- Use Docker secrets or environment variables in CI/CD pipelines
- Use Docker's `--secret` flag in production for sensitive data

### Schema Organization

The NASCAR schema is organized under a sport root folder:

- `nascar/ddl/` - ordered DDL migrations by object type
  - `nascar/ddl/tables/`
  - `nascar/ddl/foreign_keys/`
  - `nascar/ddl/unique_keys/`
  - `nascar/ddl/triggers/`
  - `nascar/ddl/functions/`
  - `nascar/ddl/stored_procedures/`
  - `nascar/ddl/views/`
  - `nascar/ddl/indexes/`
  - `nascar/ddl/constraints/`
- `nascar/seed/` - seed data scripts that run after all DDL
- `nascar/migrations/` - forward migrations for existing DBs (not auto-executed on init)
- `nascar/queries/` - non-bootstrap SQL query files only (not auto-executed)

MariaDB executes init files lexically, so file numbering controls deterministic execution order.
Seed scripts are one file per target table (for example, all `data_sources` inserts in one file).

Current NASCAR seeds (see `nascar/seed/README.md`):

- `9000-load_nascar_database_snapshot.sql.gz` — full `nascar` data snapshot (INSERT-only dump). Sync before build:
  ```bash
  ./script/sync-seed-snapshot
  ```
  Default source: `../fantasy-sports-airflow/db/backups/20260525T031712Z.sql.gz`.
- `9001-insert_dfs_seed.sql` — idempotent DraftKings provider row (`id=1`) for ML (`DRAFTKINGS_DFS_ID`).
- `9002-insert_dfs_scoring_rules_seed.sql` — idempotent DraftKings Cup scoring rules (`cup_default`, version 1).

The snapshot already includes `dfs` and `dfs_scoring_rules`; `9001`/`9002` re-apply the same rows for partial seed updates.

On a database that was initialized before the DFS seeds existed, apply them with:

```bash
./script/query -f nascar/seed/9001-insert_dfs_seed.sql
./script/query -f nascar/seed/9002-insert_dfs_scoring_rules_seed.sql
```

## Quick Start with Scripts

The repository includes convenient shell scripts for common operations:

### Setup

Initial setup - builds the Docker image:

```bash
./script/setup
```

**What it does:**
- Executes the build script to compile the Docker image
- Prepares the environment for running the database

**Usage:**
- Run this once to set up the database for the first time
- Run it again if you've made changes to the Dockerfile or DDL files

### Build

Rebuild the Docker image from scratch:

```bash
./script/build
```

**What it does:**
- Creates or updates the `fantasy-sports-db:latest` Docker image
- Compiles the Dockerfile with all DDL scripts included
- Useful for picking up any schema changes

**Usage:**
- Use this when you've modified SQL files under `nascar/ddl/` or `nascar/seed/`
- Use DEBUG environment variable for verbose output: `DEBUG=1 ./script/build`

### Start Server

Start the MariaDB database container:

```bash
./script/server
```

**What it does:**
- Launches a Docker container running MariaDB with the fantasy-sports-db image
- Initializes the database by running all scripts from DDL subfolders in `nascar/ddl/` first, then `nascar/seed/`
- Exposes the database on `localhost:36000` (override with `DATABASE_PORT` in `.env`)
- Streams container logs to the terminal
- Gracefully shuts down on Ctrl+C (SIGINT/SIGTERM)

**Default Connection Details:**
- **Host:** `localhost` or `127.0.0.1`
- **Port:** `36000` (host; `./script/server` default)
- **Root User:** `root`
- **Root Password:** `root` (default, from .env)
- **Database:** `nascar`
- **Database User:** `username` (default, from .env)
- **Database Password:** `password` (default, from .env)

**Customizing Credentials:**

Edit the `.env` file to customize credentials:

```bash
# Edit .env to change credentials
nano .env
```

Example `.env` file:

```env
DB_ROOT_PASSWORD=my_secure_root_pass
DB_USER=myappuser
DB_PASSWORD=my_secure_user_pass
```

The `script/server` automatically loads credentials from `.env`:

```bash
# Credentials are automatically loaded and used
./script/server
```

**To get started:**

1. Copy `.env.example` to `.env` (already done by default)
2. Edit `.env` with your desired credentials
3. Run `./script/server`

**Usage:**
- Run after building to start the database server
- Keeps running in foreground for easy log monitoring
- Press Ctrl+C to stop the server
- Use environment variables to customize credentials for different environments

**Example connection strings:**
```
# Default (./script/server)
mysql://username:password@localhost:36000/nascar

# Root
mysql://root:root@localhost:36000/nascar
```

### Clear Database

Stop and remove the container and Docker image:

```bash
./script/clear-db
```

**What it does:**
- Stops the running `fantasy-sports-db` container
- Removes the container
- Removes the `fantasy-sports-db:latest` Docker image
- Cleans up all resources related to the database

**Usage:**
- Use when you want to completely reset the database
- Use before pushing changes to ensure a clean build
- Use when debugging build issues
- Use `DEBUG=1 ./script/clear-db` for verbose output

### Query (ad-hoc SQL)

Run SQL against the running container (no migration ledger). Sets `pager less -SFX` before your SQL:

```bash
./script/query "SELECT COUNT(*) FROM nascar.weeks"
./script/query -f nascar/queries/data-clean-up.sql
```

Requires `./script/server` to be running.

### Migrate (ledger-tracked)

Apply one migration file and record it in `nascar.schema_migrations`:

```bash
./script/migrate nascar/migrations/20260525T000000_create_schema_migrations_table.sql
```

Re-running the same basename exits with an error. See `nascar/migrations/README.md`.

## Security Best Practices

### Using .env Files (Recommended)

This repository uses `.env` files for managing credentials safely:

- **`.env`** - Contains your actual credentials (gitignored, never committed)
- **`.env.example`** - Template file with placeholder values (committed to repo)

**Setup:**
```bash
# Copy the example file (usually done automatically)
cp .env.example .env

# Edit with your credentials
nano .env

# Run scripts - credentials are automatically loaded
./script/server
```

**Why this is secure:**
- Credentials are loaded from environment files, not hardcoded in scripts
- Credentials are not printed to console or logs
- `.env` is listed in `.gitignore` and never committed to version control
- Each developer/environment can have different credentials

### Protecting Sensitive Data

1. **Never print credentials**
   - Scripts load credentials from `.env` but don't display them
   - Protects against accidental exposure in logs or screenshots

2. **Version control safety**
   ```bash
   # Verified in .gitignore
   cat .gitignore
   # Should show:
   # .env
   # .env.local
   ```

3. **Generate strong passwords for production**
   ```bash
   # Generate a secure password
   openssl rand -base64 32
   
   # Update .env with the new password
   sed -i 's/DB_ROOT_PASSWORD=.*/DB_ROOT_PASSWORD=YOUR_SECURE_PASSWORD/' .env
   ```

4. **Docker Secrets (for Docker Swarm production)**
   ```bash
   # Create secrets
   echo "secure_root_password" | docker secret create db_root_password -
   echo "secure_user_password" | docker secret create db_user_password -
   
   # Use in docker-compose.yml with secrets
   ```

5. **CI/CD Pipeline Integration**
   - Use CI/CD platform's secret management (GitHub Secrets, GitLab CI Variables, etc.)
   - Never commit `.env` files with real credentials
   - Rotate credentials regularly
   - Use different credentials per environment (dev, staging, prod)

### Network Security

- The database only listens on `localhost:36000` by default when using `./script/server` (safe for local development)
- In production, use:
  - Private Docker networks
  - Firewall rules
  - VPN access
  - Cloud provider's security groups

### Development Guidelines

- Use different credentials for each environment
- Rotate passwords periodically
- Use strong, randomly generated passwords in production
- Never use default credentials in production
- Monitor database access logs

## Connection from External Applications

To connect from the fantasy-sports-airflow or other applications:

```javascript
// Example Node.js connection
const connection = await mariadb.createConnection({
  host: 'localhost',
  port: 36000,
  user: 'root',
  password: 'root',
  database: 'nascar'
});
```

```bash
# Command line connection
mysql -u root -proot -h localhost -D nascar
```

## Troubleshooting

### Port Already in Use
If port 36000 is already in use:
```bash
# Find what's using port 36000
lsof -i :36000

# Stop the container
./script/clear-db
```

### Unable to Connect
- Ensure the server is running: `docker ps | grep fantasy-sports-db`
- Check container logs: `docker logs fantasy-sports-db`
- Verify port mapping: `docker port fantasy-sports-db`

### Schema Issues
If you've modified DDL or seed files:
```bash
# Rebuild and restart (fresh volume replays DDL + seed only)
./script/clear-db
./script/build
./script/server
```

If you've changed an **existing** database without rebuilding:
```bash
./script/migrate nascar/migrations/YYYYMMDDTHHMMSS_your_change.sql
```