#!/bin/sh
# starting mariadb in order to config database
service mariadb start
if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
    # database configurations
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql -u root -e "CREATE USER IF NOT EXISTS'${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';"
    mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
    mysql -u root -e "FLUSH PRIVILEGES;"
else
    echo "DB already configured"
fi
# stopping mariadb in order to run it on foreground. service stop wasn't enough
kill $(cat /var/run/mysqld/mysqld.pid)
exec mysqld --bind-address=0.0.0.0