
FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y wget unzip php-fpm php-mysql php-xml php-gd php-curl php-mbstring \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Download WordPress and extract it
RUN wget -q https://wordpress.org/latest.tar.gz \
    && tar xzf latest.tar.gz --strip-components=1 \
    && rm latest.tar.gz

# Download WordPress CLI
RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

