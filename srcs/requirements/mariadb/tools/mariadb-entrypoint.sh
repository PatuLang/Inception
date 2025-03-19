#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --group=mysql

    # echo "Starting MariaDB temporarily..."
	# mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &

    # echo "Waiting for MariaDB to start..."
    # until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
	# 	    sleep 2
	# done

    echo "Setting up database and users..."
	mysql --user=mysql --bootstrap <<-EOF
		FLUSH PRIVILEGES;
		ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
		CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
		CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
		GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
		FLUSH PRIVILEGES;
	EOF

    
    # echo "Shutting down temporary MariaDB..."
    # mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -uroot -p"$MYSQL_ROOT_PASSWORD"
fi

echo "Starting MariaDB"
exec mysqld --user=mysql
