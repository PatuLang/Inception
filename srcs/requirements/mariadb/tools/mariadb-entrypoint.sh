#!/bin/sh

set -e

# if [ ! -e /etc/my.cnf.d/mariadb-server.cnf ]; then
echo "Applying MariaDB configuration..."
cat << EOF > /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
user=mysql
socket=/run/mysqld/mysqld.sock
pid-file=/run/mysqld/mariadb.pid
log_error=/var/log/mysql/error.log
port=3306
bind-address=0.0.0.0
skip-networking=0
skip-name-resolve
skip-host-cache

EOF
# fi

chown -R mysql:mysql /var/run/mysqld && \
chown -R mysql:mysql /var/log/mysql && \
chown -R mysql:mysql /var/lib/mysql

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
