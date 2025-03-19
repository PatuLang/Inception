#!/bin/bash

set -e

echo "Waiting for WordPress to be fully up..."
until curl -sSf "http://$WORDPRESS_HOST/wp-login.php" > /dev/null; do
    sleep 2
done

echo "✅ WordPress is up!"

cat << EOF >> /etc/nginx/http.d/default.conf
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/nginx/ssl/plang.crt;
    ssl_certificate_key /etc/nginx/ssl/plang.key;
    ssl_protocols TLSv1.3;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ [^/]\.php(/|\$) {
        try_files \$fastcgi_script_name =404;

        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
    }
}
EOF

echo "Nginx configuration generated successfully!"
echo "Starting Nginx..."
exec nginx -g 'daemon off;'
