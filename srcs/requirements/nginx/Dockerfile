FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y nginx openssl \
 && rm -rf /var/lib/apt/lists/*

# directorios de configuración que copiaremos
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./sites-enabled/ /etc/nginx/sites-enabled/

# EXPOSE 443

COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
