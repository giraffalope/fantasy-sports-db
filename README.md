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

The database schema is organized by sport in the `ddl/<sport>/` directory:

- `ddl/nascar/` - NASCAR database tables and constraints

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
- Use this when you've modified DDL files in `ddl/nascar/`
- Use DEBUG environment variable for verbose output: `DEBUG=1 ./script/build`

### Start Server

Start the MariaDB database container:

```bash
./script/server
```

**What it does:**
- Launches a Docker container running MariaDB with the fantasy-sports-db image
- Initializes the database with all DDL scripts from `ddl/nascar/`
- Exposes the database on `localhost:3306`
- Streams container logs to the terminal
- Gracefully shuts down on Ctrl+C (SIGINT/SIGTERM)

**Default Connection Details:**
- **Host:** `localhost` or `127.0.0.1`
- **Port:** `3306`
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
# Default
mysql://root:root@localhost:3306/nascar

# Custom
mysql://myuser:my_secure_user_pass@localhost:3306/nascar
sql://root:my_secure_root_pass@localhost:3306/nascar
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

- The database only listens on `localhost:3306` by default (safe for local development)
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
  port: 3306,
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
If port 3306 is already in use:
```bash
# Find what's using port 3306
lsof -i :3306

# Stop the container
./script/clear-db
```

### Unable to Connect
- Ensure the server is running: `docker ps | grep fantasy-sports-db`
- Check container logs: `docker logs fantasy-sports-db`
- Verify port mapping: `docker port fantasy-sports-db`

### Schema Issues
If you've modified DDL files:
```bash
# Rebuild and restart
./script/clear-db
./script/setup
./script/server
```