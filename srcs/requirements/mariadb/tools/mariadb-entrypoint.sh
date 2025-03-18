#!/bin/sh

set -e

if [ ! -e /etc/my.cnf.d/mariadb-server.cnf ]; then
echo "Applying MariaDB configuration..."
cat << EOF > /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
skip-name-resolve
skip-host-cache
EOF
fi

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql --skip-test-db --group=mysql
echo "MariaDB started. Setting up users and database..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
mysql -u root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mysql -u root -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
mysql -u root -e "FLUSH PRIVILEGES;"
fi

mysqladmin shutdown
exec mysqld_safe
