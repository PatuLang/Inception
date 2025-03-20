#!/bin/bash

set -e

echo "Waiting for WordPress to be fully up..."
until [ -f "/var/www/html/wp-config.php" ]; do
    sleep 2
done

echo "WordPress is up! Configuring Nginx"

if [ ! -f "$CERTS_KEY" ] || [ ! -f "$CERTS_CRT" ]; then
  echo "SSL certificates not found. Generating new certificates..."
  
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERTS_KEY" \
    -out "$CERTS_CRT" \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/CN=$DOMAIN_NAME"

    chmod 600 "$CERTS_KEY"
    chmod 600 "$CERTS_CRT"
fi

cat << EOF >> /etc/nginx/http.d/default.conf
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    http2 on;
    server_name $DOMAIN_NAME;

    ssl_protocols TLSv1.3;
    ssl_certificate_key $CERTS_KEY;
    ssl_certificate $CERTS_CRT;

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
