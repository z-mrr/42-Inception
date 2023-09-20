#!/bin/sh
#dir for self signed certificates
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -new -keyout /etc/nginx/ssl/jdias-mo.key -out /etc/nginx/ssl/jdias-mo.crt -subj "/CN=jdias-mo/O=42/OU=42Porto/C=PT/ST=Porto/L=Porto/emailAddress=jdias-mo@42.fr"
#running nginx on foreground
exec nginx -g "daemon off;"