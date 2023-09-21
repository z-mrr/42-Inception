FROM debian:bullseye
RUN apt-get update && \
	apt-get install -y wget php-mysqli php-fpm
COPY ./tools/docker-entrypoint.sh /scripts/docker-entrypoint.sh
RUN chmod +x /scripts/docker-entrypoint.sh
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

