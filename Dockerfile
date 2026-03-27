# Use the latest stable MariaDB image based on Ubuntu
FROM mariadb:latest

# Set non-sensitive environment variables
ENV MYSQL_DATABASE=nascar
ENV MARIADB_AUTO_UPGRADE=1

# Copy all DDL files to the initialization directory
# MariaDB will automatically execute .sql files in alphabetical order
COPY ddl/nascar/ /docker-entrypoint-initdb.d/

# Optional: Add initialization script if needed
# COPY init.sh /init.sh
# RUN chmod +x /init.sh
# ENTRYPOINT ["/init.sh"]

# MariaDB will use the default entrypoint which executes SQL files from /docker-entrypoint-initdb.d/
EXPOSE 3306
