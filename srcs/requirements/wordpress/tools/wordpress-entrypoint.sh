#!/bin/bash

set -e

WORDPRESS_CONFIG_PATH="/var/www/html/wp-config.php"

echo "Waiting for MariaDB to start..."
until mysqladmin ping -h"$MYSQL_HOST" --silent; do
    sleep 2
done

echo "MariaDB is up and running."

if [ ! -f "$WORDPRESS_CONFIG_PATH" ]; then
    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php $WORDPRESS_CONFIG_PATH

    sed -i "s/database_name_here/$MYSQL_DATABASE/" $WORDPRESS_CONFIG_PATH
    sed -i "s/username_here/$MYSQL_USER/" $WORDPRESS_CONFIG_PATH
    sed -i "s/password_here/$MYSQL_PASSWORD/" $WORDPRESS_CONFIG_PATH
    sed -i "s/localhost/$MYSQL_HOST/" $WORDPRESS_CONFIG_PATH

    WORDPRESS_SALT_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    echo "$WORDPRESS_SALT_KEYS" | while read -r line; do
        key=$(echo "$line" | cut -d "'" -f 2)
        value=$(echo "$line" | cut -d "'" -f 4)
        sed -i "s/define('$key', 'put your unique phrase here');/define('$key', '$value');/" $WORDPRESS_CONFIG_PATH
    done

    echo "wp-config.php configured successfully."
fi

if ! wp core is-installed --allow-root --path=/var/www/html; then
    echo "Installing WordPress..."
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --path=/var/www/html

    echo "WordPress installed successfully."

    wp user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" --role=editor --user_pass="$WORDPRESS_USER_PASSWORD" --allow-root --path=/var/www/html
    echo "Additional WordPress user created."
fi

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm83 -F
