FROM alpine:3.20.3

EXPOSE 3306

RUN apk update && apk add --no-cache mariadb mariadb-client mariadb-common bash

COPY tools/mariadb-entrypoint.sh /usr/local/bin/
COPY ./conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld
RUN mkdir -p /var/log/mysql && chown -R mysql:mysql /var/log/mysql
RUN mkdir -p /var/lib/mysql && chown -R mysql:mysql /var/lib/mysql

ENTRYPOINT [ "mariadb-entrypoint.sh" ]
