#!/bin/sh
#configure php to listen on port 9000
sed -i '/listen = /c\listen = 9000' /etc/php/7.4/fpm/pool.d/www.conf
#this || service start and stop in order for php to run
mkdir -p /run/php
#dir for wordpress
mkdir -p /var/www/html/${WP_URL}
cd /var/www/html/${WP_URL}
if [ ! -f "/var/www/html/${WP_URL}/wp-config.php" ]; then
	#download && install wp-cli
	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp
	chmod +x /usr/local/bin/wp
	#download and configure wp to connect to database
	wp core download --allow-root
	#time for db to be up
	sleep 3
	cp wp-config-sample.php wp-config.php
	sed -i "s/username_here/${DB_USER}/g" wp-config.php
	sed -i "s/password_here/${DB_PASSWORD}/g" wp-config.php
	sed -i "s/localhost/${DB_HOST}/g" wp-config.php
	sed -i "s/database_name_here/${DB_NAME}/g" wp-config.php
	#install wp with following config
	wp core install --url=${WP_URL} --title=${WP_TITLE} --admin_user=${WP_ADMIN} --admin_password=${WP_PASSWORD} --admin_email=${WP_EMAIL} --skip-email --allow-root
else
	echo "WordPress already installed"
fi
#execute php in wp dir on foreground
exec php-fpm7.4 -F