#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --group=mysql

    echo "Starting MariaDB temporarily..."
	mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &

    echo "Waiting for MariaDB to start..."
    until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
		    sleep 2
	done

    echo "Setting up users and database..."
    mysql -u root -e "FLUSH PRIVILEGES;"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'";
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
    mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    echo "Shutting down temporary MariaDB..."
    mysqladmin shutdown --socket=/var/run/mysqld/mysqld.sock -uroot -p"$MYSQL_ROOT_PASSWORD"
fi

exec mysqld_safe
