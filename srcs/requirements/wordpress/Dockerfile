
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y wget unzip php-fpm php-mysql php-xml php-gd php-curl php-mbstring \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Descargar WordPress y extraerlo
RUN wget -q https://wordpress.org/latest.tar.gz \
 && tar xzf latest.tar.gz --strip-components=1 \
 && rm latest.tar.gz

# permisos
RUN chown -R www-data:www-data /var/www/html

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

