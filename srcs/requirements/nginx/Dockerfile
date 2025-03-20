FROM alpine:3.20.6

EXPOSE 443

RUN apk update && apk add --no-cache nginx openssl bash curl

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

ENTRYPOINT [ "nginx-entrypoint.sh" ]
