FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y mariadb-server mariadb-client && rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/my.cnf

VOLUME ["/var/lib/mysql"]

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
