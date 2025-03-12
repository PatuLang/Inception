FROM alpine:3.20.6

RUN apk update && apk add --no-cache nginx openssl bash

COPY tools/nginx-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

RUN mkdir -p /etc/nginx/ssl && \
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/nginx/ssl/plang.key \
	-out /etc/nginx/ssl/plang.crt \
	-subj "/CN=$DOMAIN_NAME"

EXPOSE 443

ENTRYPOINT [ "nginx-entrypoint.sh" ]
