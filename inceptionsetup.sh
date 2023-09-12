#!/bin/sh
sudo adduser jdias-mo
sudo usermod -aG sudo jdias-mo
if [ "$USER" = "root" ] || groups "$USER" | grep -q "\bsudo\b"; then
    echo "Setting up Inception..."
else
    echo "$USER is not a member of the sudo group. Exiting."
    exit 1
fi
mkdir ~/Inception
mkdir ~/Inception/srcs
mkdir ~/Inception/srcs/requirements
mkdir ~/Inception/srcs/requirements/mariadb
mkdir ~/Inception/srcs/requirements/mariadb/conf
mkdir ~/Inception/srcs/requirements/mariadb/tools
mkdir ~/Inception/srcs/requirements/nginx
mkdir ~/Inception/srcs/requirements/nginx/conf
mkdir ~/Inception/srcs/requirements/nginx/tools
mkdir ~/Inception/srcs/requirements/tools
mkdir ~/Inception/srcs/requirements/wordpress
mkdir ~/Inception/srcs/requirements/wordpress/conf
mkdir ~/Inception/srcs/requirements/wordpress/tools
sudo apt-get update
sudo apt-get install curl -y
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo sh -c 'echo "127.0.0.1 jdias-mo.42.fr" >> /etc/hosts'
echo 'FROM debian:bullseye
RUN apt-get update
RUN apt-get install nginx -y
RUN apt-get install openssl -y
RUN mkdir /etc/nginx/ssl
RUN openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/jdias-mo.key -out /etc/nginx/ssl/jdias-mo.crt -subj "/CN=jdias-mo/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto/emailAddress=jdias-mo@student.42porto.com"
COPY conf/default.conf /etc/nginx/conf.d/default.conf
ENTRYPOINT nginx -g "daemon off;"' > ~/Inception/srcs/requirements/nginx/Dockerfile
echo 'server {
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name  jdias-mo.42.fr;

    index index.php index.html index.htm;

    root /var/www/html;

    ssl_certificate /etc/nginx/ssl/jdias-mo.crt;
    ssl_certificate_key /etc/nginx/ssl/jdias-mo.key;
    ssl_protocols TLSv1.3;
    
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        fastcgi_pass   wordpress:9000;
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        include        fastcgi_params;
}' > ~/Inception/srcs/requirements/nginx/conf/default.conf
