FROM ubuntu:16.04

LABEL maintainer="BaBeuloula <babeuloula@gmail.com>"

# On crée les variables d'environement pour les utiliser plus facilement
ENV APACHE_CONF_FILE /etc/apache2/apache2.conf
ENV PHP_CONF_FILE /etc/php/7.2/apache2/php.ini

RUN apt-get update && apt-get install -y --no-install-recommends \
                apache2 \
                software-properties-common \
                python-software-properties \
                supervisor \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/*

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/apache2

RUN apt-key update && apt-get update && apt-get install -y --no-install-recommends \
                libapache2-mod-php7.2 \
                php7.2 \
                php7.2-cli \
                php7.2-curl \
                php7.2-dev \
                php7.2-gd \
                php7.2-imap \
                php7.2-intl \
                php7.2-mbstring \
                php7.2-mysql \
                php7.2-pgsql \
                php7.2-pspell \
                php7.2-xml \
                php7.2-xmlrpc \
                php-apcu \
                php-memcached \
                php-pear \
                php-redis \
        && apt-get clean \
        && rm -fr /var/lib/apt/lists/*

RUN a2enmod rewrite
RUN a2enmod expires

# Installation de HTTP2
RUN apt-get --only-upgrade install -y apache2 && apt-get update -y && apt-get upgrade -y && apt-get install apache2 -y

# On active HTTP2
RUN a2enmod http2
RUN echo "Protocols h2 http/1.1" >> $APACHE_CONF_FILE


# On ajoute localhost comme nom de serveur
RUN echo "ServerName localhost" >> $APACHE_CONF_FILE

# On cache la signature du serveur
RUN echo "ServerSignature Off" >> $APACHE_CONF_FILE
RUN echo "ServerTokens Prod" >> $APACHE_CONF_FILE


RUN echo "upload_max_filesize = 4096M" >> $PHP_CONF_FILE
RUN echo "post_max_size = 4096M" >> $PHP_CONF_FILE
RUN echo "session.gc_maxlifetime = 86400" >> $PHP_CONF_FILE


# On set la timezone en Europe
RUN echo "Europe/Paris" > /etc/timezone
RUN dpkg-reconfigure -f noninteractive tzdata


COPY conf/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY script/run.sh /run.sh

VOLUME /var/www/html
VOLUME /etc/apache2/sites-available

RUN chmod 755 /run.sh

COPY conf/config /config

EXPOSE 80
EXPOSE 443

CMD ["/run.sh"]