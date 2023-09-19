## 42-Inception
### Installing Docker on Ubuntu
#### Remove conflitcts (skip if new VM)
```
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
```
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras
```
```
sudo rm -rf /var/lib/docker
```
```
sudo rm -rf /var/lib/containerd
```
#### Install using Apt repository
Add Docker's official GPG key:
```
sudo apt-get update
```
```
sudo apt-get install ca-certificates curl gnupg
```
```
sudo install -m 0755 -d /etc/apt/keyrings
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
```
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```
Add the repository to Apt sources:
```
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
```
sudo apt-get update
```
Install the Docker packages
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Verify that the Docker Engine installation is successful by running the hello-world image
```
sudo docker run hello-world
```
#### Manage Docker as non-root user
Check if ```docker``` group exists and if the user is on it
```
sudo cat /etc/group | grep docker
```
If it doesn't exist, create the ```docker``` group
```
sudo groupadd docker
```
Add user to the ```docker``` group
```
sudo usermod -aG docker $USER
```
Reboot or 
```
newgrp docker
```
Verify that you can run ```docker``` commands without ```sudo```
```
docker run hello-world
```
If you get ```WARNING: Error loading config file: /home/user/.docker/config.json -
stat /home/user/.docker/config.json: permission denied```
```
sudo rm -rf ~/.docker/
```
### NGINX
Domain name
```
sudo sh -c 'echo "127.0.0.1 jdias-mo.42.fr" >> /etc/hosts'
```
#### Dockerfile
```oenssl``` to generate self-signed SSL certificate and key<br>
```daemon off``` to run on the foreground as it is in a container
```
FROM debian:bullseye
RUN apt-get update && apt-get install -y nginx openssl
RUN mkdir /etc/nginx/ssl && openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/jdias-mo.key -out /etc/nginx/ssl/jdias-mo.crt -subj "/CN=jdias-mo/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto/emailAddress=jdias-mo@student.42porto.com"
COPY ./jdias-mo.42.fr /etc/nginx/sites-available/jdias-mo.42.fr
RUN ln -s /etc/nginx/sites-available/jdias-mo.42.fr /etc/nginx/sites-enabled/
CMD nginx -g "daemon off;"                       
```
#### Conf file jdias-mo.42.fr
Will be on ```/etc/nginx/sites-available/``` and linked to ```/etc/nginx/sites-enables```<br>
```TLSv1.3``` only
```
server {
    listen       443 ssl;
    listen  [::]:443 ssl;

    server_name  jdias-mo.42.fr;

    index index.php index.html index.htm;

    root /var/www/html/jdias-mo.42.fr;

    ssl_certificate /etc/nginx/ssl/jdias-mo.crt;
    ssl_certificate_key /etc/nginx/ssl/jdias-mo.key;
    ssl_protocols TLSv1.3;

    location ~ \.php$ {
        fastcgi_pass   wordpress:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
    }
}
```
### WordPress
#### Dockerfile
```
FROM debian:bullseye
RUN apt-get update && \
	apt-get install -y wget php-mysqli php-fpm
RUN sed -i '/listen = /c\listen = 9000' /etc/php/7.4/fpm/pool.d/www.conf && \
	mkdir -p /run/php
WORKDIR /var/www/html/jdias-mo.42.fr/
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
	chmod +x /usr/local/bin/wp
RUN wp core download --allow-root && \
	sed -i "s/username_here/$DB_USER/g" wp-config-sample.php && \
	sed -i "s/password_here/$DB_PASSWORD/g" wp-config-sample.php && \
	sed -i "s/localhost/$DB_HOSTNAME/g" wp-config-sample.php && \
	sed -i "s/database_name_here/$DB_NAME/g" wp-config-sample.php && \
	cp wp-config-sample.php wp-config.php
#COPY ./tools/wordpress-entrypoint.sh /scripts/wordpress-entrypoint.sh
#RUN chmod +x /scripts/wordpress-entrypoint.sh
#ENTRYPOINT /scripts/wordpress-entrypoint.sh
CMD php-fpm7.4 -F

```
### MariaDB
#### Dockerfile
```
FROM debian:bullseye
RUN apt-get update -y && \
	apt-get install -y mariadb-server
RUN mkdir -p /var/run/mysqld && \
	chown -R mysql:mysql /var/run/mysqld && \
	chmod 777 /var/run/mysqld
COPY ./conf/my.cnf /etc/mysql/my.cnf
RUN chmod 744 /etc/mysql/my.cnf
COPY ./tools/mariadb-entrypoint.sh /scripts/
RUN chmod +x /scripts/mariadb-entrypoint.sh
#ENTRYPOINT /scripts/mariadb-entrypoint.sh
#WORKDIR /var/lib/mysql
#CMD mysqld_safe
```
### Entrypoint script
```

```
### Docker Compose
```
services:
  nginx:
    build: ./requirements/nginx
    container_name: nginx
    image: nginx:1.0.0
    ports:
      - "443:443"
    depends_on:
      - wordpress
    #restart: always
    networks:
      - inception
    volumes:
      - wp-data:/var/www/html/jdias-mo.42.fr

  wordpress:
    build: ./requirements/wordpress
    container_name: wordpress
    image: wordpress:1.0.0
    expose:
      - "9000"
    depends_on:
      - mariadb
    env_file:
      - .env
    #restart: always
    networks:
      - inception
    volumes:
      - wp-data:/var/www/html/jdias-mo.42.fr

  mariadb:
    build: ./requirements/mariadb
    container_name: mariadb
    image: mariadb:1.0.0
    expose:
      - "3306"
    env_file:
      - .env
    #restart: always
    networks:
      - inception
    volumes:
      - db-data:/var/lib/mysql

volumes:
  wp-data:
    name: wp-data
    driver: local
    driver_opts:
      type: none
      device: /home/jdias-mo/data/wp-data
      o: bind
  db-data:
    name: db-data
    driver: local
    driver_opts:
      type: none
      device: /home/jdias-mo/data/db-data
      o: bind

networks:
  inception:
    name: inception
    driver: bridge
```
#### .env file
```
DB_NAME=wordpressdb
DB_USER=jdias-mo
DB_PASSWORD=userpw
DB_HOST=mariadb
DB_ROOT_PASSWORD=rootpw
```
### Best practices for building containers
One app per container<br>
PID1: using ENTRYPOINT, CMD in Dockerfile or using a shell script to prepare the environment and launching the main process<br>
Optimize for the Docker build cache: update && install in the same step<br>
Remove unnecessary tools for added security<br>
Build the smallest image possible<br>
Properly tag images: not using the default latest tag

#### Useful commands
```docker ps```
```docker rm -f $(docker ps -aq)```
```docker images```
```docker image prune```
```docker inspect```
```docker networks```
```docker compose up --build```
