#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --rpm > /dev/null

    echo "Setting up database and users..."
	mysqld --bootstrap --datadir=/var/lib/mysql --user=mysql <<-EOF

    USE mysql;
	FLUSH PRIVILEGES;
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
	CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
	GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
	FLUSH PRIVILEGES;
	EOF

fi

echo "Starting MariaDB"
exec mysqld --user=mysql
