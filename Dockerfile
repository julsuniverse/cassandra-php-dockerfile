FROM php:7.1-cli

RUN apt-get update && apt-get install -y wget multiarch-support

# Install openssl
RUN wget "http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.0.0_1.0.2g-1ubuntu4_amd64.deb" \
    && dpkg -i libssl1.0.0_1.0.2g-1ubuntu4_amd64.deb

# Intall libuv
RUN wget "https://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.35.0/libuv1_1.35.0-1_amd64.deb" \
    && dpkg -i libuv1_1.35.0-1_amd64.deb
RUN wget "https://downloads.datastax.com/cpp-driver/ubuntu/16.04/dependencies/libuv/v1.35.0/libuv1-dev_1.35.0-1_amd64.deb" \
    && dpkg -i libuv1-dev_1.35.0-1_amd64.deb

RUN ln -s /usr/lib/libuv.so.1 /usr/lib/libuv.so

# Install dependecies
RUN apt-get update && apt-get install -y libpq-dev libgmp-dev git cmake make unzip \
    && ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/local/include/ \
    && docker-php-ext-configure gmp \
    && docker-php-ext-install gmp

# Install datastax php-driver fox cassandra
RUN wget "https://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.15.3/cassandra-cpp-driver_2.15.3-1_amd64.deb" \
    && dpkg -i cassandra-cpp-driver_2.15.3-1_amd64.deb
RUN wget "https://downloads.datastax.com/cpp-driver/ubuntu/16.04/cassandra/v2.15.3/cassandra-cpp-driver-dev_2.15.3-1_amd64.deb" \
    && dpkg -i cassandra-cpp-driver-dev_2.15.3-1_amd64.deb

# Install and enable Cassandra PHP extension
RUN pecl install cassandra  \
    && docker-php-ext-enable cassandra \
    && rm -rf /tmp/pear \
    && php -m | grep cassandra

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet

ENV COMPOSER_ALLOW_SUPERUSER 1

WORKDIR /app

COPY ./ ./

RUN composer install --no-dev --no-scripts --prefer-dist --optimize-autoloader