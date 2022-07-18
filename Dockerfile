FROM php:7.4-apache
ARG APP_ENV

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV TZ=America/Mexico_City

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/

RUN apt-get update && apt-get install -y libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev
RUN pecl install memcached-3.2.0
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN apt-get update && \
    apt-get install -y default-mysql-client unzip vim cron openssl

RUN if [ "$APP_ENV" = "development" ] ; then install-php-extensions \
    intl mysqli gd zip pdo_mysql soap bcmath sockets scoutapm xdebug; else install-php-extensions \
    intl mysqli gd zip pdo_mysql soap bcmath sockets scoutapm; fi

RUN if [ "$APP_ENV" = "development" ] ; then echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.idekey=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get update && \
  apt install -y locales-all && \
  apt install -y tmux && \
  apt install -y openssh-server && \
  service ssh start
EXPOSE 22/tcp

RUN a2enmod rewrite

EXPOSE 80
