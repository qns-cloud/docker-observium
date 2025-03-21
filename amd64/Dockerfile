# Docker container for Observium Community Edition
#
# Requires a linked MySQL or MariaDB container (ex.: `--link observiumdb:observiumdb`)
# Example usage:
# 1. MySQL or MariaDB container
#    $ mkdir -p /home/docker/observium/data
#    $ docker run --name observiumdb \
#        -v /home/docker/observium/data:/var/lib/mysql \
#        -e MYSQL_ROOT_PASSWORD=passw0rd \
#        -e MYSQL_USER=observium \
#        -e MYSQL_PASSWORD=passw0rd \
#        -e MYSQL_DATABASE=observium \
#        mariadb
#
# 2. This Observium container
#    $ mkdir -p /home/docker/observium/logs /home/docker/observium/rrd
#    $ docker run --name observiumapp --link observiumdb:observiumdb \
#        -v /home/docker/observium/logs:/opt/observium/logs \
#        -v /home/docker/observium/rrd:/opt/observium/rrd \
#        -e OBSERVIUM_ADMIN_USER=admin \
#        -e OBSERVIUM_ADMIN_PASS=passw0rd \
#        -e OBSERVIUM_DB_HOST=observiumdb \
#        -e OBSERVIUM_DB_USER=observium \
#        -e OBSERVIUM_DB_PASS=passw0rd \
#        -e OBSERVIUM_DB_NAME=observium \
#        -e OBSERVIUM_BASE_URL=http://yourserver.yourdomain:80 \
#        -p 8888:80 mbixtech/observium
#
# References:
#  - Follow platform guideline specified in https://github.com/docker-library/official-images
#

FROM ubuntu:24.04

ARG FETCH_VERSION=latest
ARG OBSERVIUM_ADMIN_USER=admin
ARG OBSERVIUM_ADMIN_PASS=passw0rd
ARG OBSERVIUM_DB_HOST=observiumdb
ARG OBSERVIUM_DB_USER=observium
ARG OBSERVIUM_DB_PASS=passw0rd
ARG OBSERVIUM_DB_NAME=observium

LABEL maintainer "somsakc@hotmail.com"
LABEL version "1.8"
LABEL description "Docker container for Observium Community Edition"
LABEL fetch_version "$FETCH_VERSION"

# set environment variables
ENV FETCH_VERSION=$FETCH_VERSION
ENV LANG=en_US.UTF-8
ENV LANGUAGE=$LANG
ENV OBSERVIUM_DIR="/opt/observium"
ENV OBSERVIUM_DB_HOST=$OBSERVIUM_DB_HOST
ENV OBSERVIUM_DB_USER=$OBSERVIUM_DB_USER
ENV OBSERVIUM_DB_PASS=$OBSERVIUM_DB_PASS
ENV OBSERVIUM_DB_NAME=$OBSERVIUM_DB_NAME

# ensure apt will not ask for things interactively
ARG DEBIAN_FRONTEND=noninteractive

# update & install base packages
RUN apt update && \
    apt upgrade -y && \
    apt install -y  cron \
                    locales \
                    supervisor \
                    logrotate \
                    curl \
                    wget

# install observium required packages
RUN apt install -y  libapache2-mod-php \
                    php-cli \
                    php-mysql \
                    php-gd \
                    php-json \
                    php-bcmath \
                    php-mbstring \
                    php-opcache \
                    php-curl \
                    php-apcu \
                    php-pear \
                    libphp-phpmailer \
                    libvirt-clients \
                    snmp \
                    fping \
                    mysql-client \
                    rrdtool \
                    subversion \
                    whois \
                    mtr-tiny \
                    ipmitool \
                    graphviz \
                    imagemagick \
                    apache2 \
                    python3-mysqldb \
                    python3-pymysql \
                    python-is-python3

# cleanup
RUN apt clean && \
    rm -f /etc/apache2/sites-available/* \
       /etc/cron.d/* \
       /etc/cron.hourly/* \
       /etc/cron.daily/* \
       /etc/cron.weekly/* \
       /etc/cron.monthly/* \
       /etc/logrotate.d/* \
       /etc/supervisord/conf.d/* && \
    rm -fr /var/log/* \
       /var/www && \
    mkdir /var/log/apache2

# set locale
RUN locale-gen $LANG

# install observium
RUN mkdir -p /opt/observium /opt/observium/logs /opt/observium/rrd && \
    chmod 755 /opt/observium /opt/observium/logs /opt/observium/rrd && \
    wget -qO - http://www.observium.org/observium-community-${FETCH_VERSION}.tar.gz | \
    tar -zxvf - -C /opt

# configure observium
RUN sed -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" \
        -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g"  \
        -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g"  \
        -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" \
        -e "$ a \$config['base_url'] = getenv('OBSERVIUM_BASE_URL');" \
        /opt/observium/config.php.default > /opt/observium/config.php

COPY observium-init.sh /opt/observium/observium-init.sh

RUN chmod a+x /opt/observium/observium-init.sh && \
    chown -R www-data:www-data /opt/observium

# configure php modules
RUN phpenmod mcrypt

# setup apache configuration and modules
COPY observium-apache24 /etc/apache2/sites-available/000-default.conf
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php8.3 && \
    a2enmod rewrite && \
    chmod 644 /etc/apache2/sites-available/000-default.conf && \
    sed -i -e 's#${APACHE_LOG_DIR}/#/opt/observium/logs/apache2-#g' /etc/apache2/apache2.conf

# configure cron and logrotate
COPY logrotate-conf /etc/logrotate.conf
COPY logrotate-cron /etc/cron.d/logrotate
COPY observium-cron /etc/cron.d/observium
RUN chmod 644 /etc/logrotate.conf /etc/cron.d/logrotate /etc/cron.d/observium

# configure working directory
WORKDIR /opt/observium

# configure entry point
COPY supervisord.conf /etc/supervisord.conf
ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

# expose tcp port
EXPOSE 80/tcp

# set volumes
VOLUME ["/opt/observium/logs","/opt/observium/rrd"]
