FROM alpine:3.20.6

RUN apk update && apk add --no-cache mariadb mariadb-client bash

COPY tools/mariadb-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

EXPOSE 3306

ENTRYPOINT [ "mariadb-entrypoint.sh" ]
