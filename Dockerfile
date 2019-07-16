FROM ubuntu:18.04

LABEL maintainer="BaBeuloula <babeuloula@gmail.com>"

ARG DEBIAN_FRONTEND=noninteractive

ENV APACHE_CONF_FILE /etc/apache2/apache2.conf
ENV PHP_CONF_FILE /etc/php/7.2/apache2/php.ini

ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y --no-install-recommends \
            supervisor \
            apache2 \
            libapache2-mod-php7.2 \
            php7.2 \
            php7.2-cli \
            php7.2-curl \
            php7.2-gd \
            php7.2-imap \
            php7.2-intl \
            php7.2-mbstring \
            php7.2-mysql \
            php7.2-xml \
            php-apcu \
            php-memcached \
    && apt clean \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer /usr/bin/composer /usr/local/bin/composer
COPY conf /etc/supervisor/conf.d/supervisord.conf
COPY script/run.sh /run.sh

RUN a2enmod rewrite && a2enmod expires && a2enmod http2 \
    && echo "Protocols h2 http/1.1" >> $APACHE_CONF_FILE \
    && echo "ServerName localhost" >> $APACHE_CONF_FILE \
    && echo "ServerSignature Off" >> $APACHE_CONF_FILE \
    && echo "ServerTokens Prod" >> $APACHE_CONF_FILE \
    && echo "upload_max_filesize = 4096M" >> $PHP_CONF_FILE \
    && echo "post_max_size = 4096M" >> $PHP_CONF_FILE \
    && echo "session.gc_maxlifetime = 86400" >> $PHP_CONF_FILE \
    && chmod 755 /run.sh \
    && service apache2 restart

VOLUME /var/www/html
VOLUME /etc/apache2/sites-available

CMD ["/run.sh"]
