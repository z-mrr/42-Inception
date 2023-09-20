FROM debian:bullseye
RUN apt update && \
	apt install -y wget php-mysqli php-fpm
COPY ./tools/docker-entrypoint.sh /scripts/docker-entrypoint.sh
RUN chmod +x /scripts/docker-entrypoint.sh
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]

