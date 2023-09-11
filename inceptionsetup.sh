#!/bin/sh
sudo apt-get update
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
ENTRYPOINT nginx -g "daemon off;"' > Dockerfile
echo 'server {
    listen       443 ssl;
    listen  [::]:443 ssl;
    server_name  jdias-mo.42.fr;

    ssl_certificate /etc/nginx/ssl/jdias-mo.crt;
    ssl_certificate_key /etc/nginx/ssl/jdias-mo.key;
    ssl_protocols TLSv1.3;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}' > default.conf
