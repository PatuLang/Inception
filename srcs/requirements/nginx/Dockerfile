FROM alpine:3.20.6

EXPOSE 443

RUN apk update && apk add --no-cache nginx openssl bash curl

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

RUN adduser -D -H -s /sbin/nologin -g www-data -G www-data www-data

RUN mkdir -p /etc/nginx/ssl
RUN sh -c openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout "$CERTS_KEY" \
	-out "$CERTS_CRT" \
	-subj "/C=FI/ST=Uusimaa/L=Helsinki/CN=$DOMAIN_NAME"

RUN chmod 600 "$CERTS_KEY"
RUN chmod 600 "$CERTS_CRT"

ENTRYPOINT [ "nginx-entrypoint.sh" ]
