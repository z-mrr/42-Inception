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
RUN apt-get update && apt-get -y install nginx openssl
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/jdias-mo.key -out /etc/nginx/ssl/jdias-mo.crt -subj "/CN=jdias-mo/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto/emailAddress=jdias-mo@student.42porto.com"
COPY conf/default.conf /etc/nginx/conf.d/default.conf
ENTRYPOINT nginx -g "daemon off;"
```
#### Conf file
```TLSv1.3``` only
```
server {
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name  jdias-mo.42.fr;

    index index.php index.html index.htm;

    root /var/www/html/wordpress;

    ssl_certificate /etc/nginx/ssl/jdias-mo.crt;
    ssl_certificate_key /etc/nginx/ssl/jdias-mo.key;
    ssl_protocols TLSv1.3;

    #every other uri
    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    #uri ending in .php
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
RUN apt-get update && apt-get install -y wget php-mysqli php-fpm
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
RUN wget https://wordpress.org/latest.tar.gz
RUN tar -zxvf latest.tar.gz
RUN rm latest.tar.gz
WORKDIR /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html/wordpress #change owner/group of the extracted files
RUN sed -i 's/listen = /c\listen = 9000' /etc/php/7.4/fpm/pool.d/www.conf
RUN mkdir -p /run/php #so php runs
ENTRYPOINT php-fpm7.4 -F #run on foreground
```
#### ```wp-conf.php```
### Docker Compose
```
services:
  nginx:
    build: ./nginx
    container_name: nginx
    image: nginx:1.0.0
    ports:
      - "443:443"
    depends_on:
      - wordpress
      - mariadb
    env_file:
      - .env
    restart: always
    networks:
      - inception
    volumes:
      - wordpress:/var/www/html

  wordpress:
    build: ./wordpress
    container_name: wordpress
    image: wordpress:1.0.0
    expose:
      - "9000"
    env_file:
      - .env
    #restart: always
    networks:
      - inception
    volumes:
      - wordpress:/var/www/html

  mariadb:
    build: ./mariadb
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
  wordpress:

networks:
  inception:
    name: inception
    driver: bridge
```
#### .env file
```

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
