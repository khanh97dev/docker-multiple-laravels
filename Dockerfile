FROM --platform=linux/amd64 alpine:3.19.0

COPY .env /.env

# Update package
RUN apk update --no-cache

# Base packages
RUN apk add --no-cache \
    bash \
    git \
    vim \
    zip \
    dcron \
    openrc \
    mysql-client \
    nodejs \
    openssh \
    curl \
    sshpass

# PHP & PHP-FPM
RUN apk add --no-cache \
    composer \
    php82-common \
    php82-fpm \
    php82-zip \
    php82-curl \
    php82-pdo \
    php82-pdo_mysql \
    php82-mysqli \
    php82-pcntl \
    php82-openssl \
    php82-mbstring \
    php82-bcmath \
    php82-ctype \
    php82-dom \
    php82-gd \
    php82-intl \
    php82-simplexml \
    php82-soap \
    php82-sodium \
    php82-xsl \
    php82-tokenizer \
    php82-fileinfo \
    php82-sockets \
    php82-xml \
    php82-xmlreader \
    php82-xmlwriter \
    php82-session \
    php82-posix

# Configure PHP
RUN sed -i 's/^memory_limit = .*/memory_limit = -1/' /etc/php82/php.ini && \
    sed -i 's/^max_execution_time = .*/max_execution_time = 600/' /etc/php82/php.ini && \
    sed -i 's/^max_input_time = .*/max_input_time = 600/' /etc/php82/php.ini

# Configure PHP-FPM to run in foreground
RUN sed -i 's/^;daemonize = yes/daemonize = no/' /etc/php82/php-fpm.conf
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php82/php-fpm.d/www.conf

# Working directory
WORKDIR /var/www/html
COPY ./docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Entrypoint runs PHP-FPM in foreground
ENTRYPOINT ["/docker-entrypoint.sh"]