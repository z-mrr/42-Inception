FROM debian:bullseye
RUN apt-get update && \
	apt-get install -y mariadb-server
COPY ./tools/docker-entrypoint.sh /scripts/
RUN chmod +x /scripts/docker-entrypoint.sh
ENTRYPOINT ["/scripts/docker-entrypoint.sh"]