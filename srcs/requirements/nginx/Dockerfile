FROM debian:bullseye
RUN apt-get update && \
    apt-get install -y nginx openssl
COPY ./conf/jdias-mo.42.fr /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/jdias-mo.42.fr /etc/nginx/sites-enabled/
COPY ./tools/docker-entrypoint.sh /scripts/
RUN chmod +x /scripts/docker-entrypoint.sh
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]