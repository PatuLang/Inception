#!/bin/sh

set -e

# if [ ! -e /etc/my.cnf.d/mariadb-server.cnf ]; then
echo "Applying MariaDB configuration..."
cat << EOF > /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
user=mysql
bind-address=0.0.0.0
skip-networking=0
skip-name-resolve
skip-host-cache
socket=/run/mysqld/mysqld.sock
port=3306

EOF
# fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --group=mysql

    echo "Starting MariaDB temporarily..."
	mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &

    until mysqladmin ping --socket=/var/run/mysqld/mysqld.sock --silent; do
		    sleep 2
	done

    echo "Setting up users and database..."
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
    mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
    mysql -u root -e "FLUSH PRIVILEGES;"
fi

mysqladmin shutdown
exec mysqld_safe
