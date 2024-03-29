FROM php:7.4-apache
ARG APP_ENV

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV TZ=America/Mexico_City

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
RUN sed -i "s!LogLevel warn!LogLevel error!g" /etc/apache2/apache2.conf

COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/


RUN apt-get update && \
    apt-get install -y default-mysql-client unzip vim cron supervisor openssl locales-all tmux openssh-server libmemcached11 libmemcachedutil2 build-essential libmemcached-dev libz-dev redis-tools

RUN pecl install memcached-3.2.0
RUN echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

RUN if [ "$APP_ENV" = "development" ] ; then install-php-extensions \
    intl mysqli gd zip pdo_mysql soap bcmath sockets scoutapm xdebug; else install-php-extensions \
    intl mysqli gd zip pdo_mysql soap bcmath sockets scoutapm; fi

RUN if [ "$APP_ENV" = "development" ] ; then docker-php-ext-enable xdebug && \
    echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_mode=req" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.remote_port=9003" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.idekey=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    echo "xdebug.client_host=host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; fi

RUN a2enmod rewrite

EXPOSE 80
