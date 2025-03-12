FROM alpine:3.20.6

RUN apk update && apk add --no-cache bash curl mariadb-client php83 php83-fpm \
	php83-phar php83-json php83-mysqli php83-curl php83-dom php83-mbstring \
	php83-openssl php83-xml php83-session

RUN cd /usr/local/bin && \
	curl -o wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp

COPY tools/wordpress-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

EXPOSE 9000

ENTRYPOINT [ "wordpress-entrypoint.sh" ]
