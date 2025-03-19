#!/bin/bash

set -e

echo "Waiting for MariaDB to start..."
until mariadb-admin ping --protocol=tcp --host=mariadb -u"$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait >/dev/null 2>&1; do                                    
	sleep 2                                                                                                                                                       
done

echo "MariaDB is up and running!"

echo "Setting file permissions for Wordpress..."
chown -R www-data:www-data /var/www/html

cd /var/www/html

if ! wp core is-installed --allow-root; then
    echo "WordPress is not installed. Installing now..."

    wp core download --allow-root

    wp config create \
        --dbname=${MYSQL_DATABASE} \
        --dbuser=${MYSQL_USER} \
        --dbpass=${MYSQL_PASSWORD} \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url=${DOMAIN_NAME} \
        --title=${WORDPRESS_TITLE} \
        --admin_user=${WORDPRESS_ADMIN_USER} \
        --admin_password=${WORDPRESS_ADMIN_PASSWORD} \
        --admin_email=${WORDPRESS_ADMIN_EMAIL} \
        --allow-root

    wp user create \
        ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} \
        --user_pass=${WORDPRESS_USER_PASSWORD} \
        --allow-root

fi

echo "Starting PHP-FPM..."
exec php-fpm83 -F
