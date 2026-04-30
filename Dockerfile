# Use the latest stable MariaDB image based on Ubuntu
FROM mariadb:latest

# Set non-sensitive environment variables
ENV MYSQL_DATABASE=nascar
ENV MARIADB_AUTO_UPGRADE=1

# Copy NASCAR DDL subfolders first, then seed files.
# MariaDB executes .sql files in lexical order after copy, so file numbering controls order.
COPY nascar/ddl/tables/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/foreign_keys/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/unique_keys/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/triggers/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/functions/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/stored_procedures/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/views/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/indexes/ /docker-entrypoint-initdb.d/
COPY nascar/ddl/constraints/ /docker-entrypoint-initdb.d/
COPY nascar/seed/ /docker-entrypoint-initdb.d/

# Optional: Add initialization script if needed
# COPY init.sh /init.sh
# RUN chmod +x /init.sh
# ENTRYPOINT ["/init.sh"]

# MariaDB will use the default entrypoint which executes SQL files from /docker-entrypoint-initdb.d/
EXPOSE 3306
