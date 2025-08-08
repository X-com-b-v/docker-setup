FROM php:7.2-fpm-buster
RUN useradd -u 1000 -s /bin/bash web
# Update outdated sources to archive.debian.org en disable security repo
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo nano nullmailer git git-flow lsb-release apt-transport-https ca-certificates \
mariadb-client rsync python2
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g-dev libpng-dev libonig-dev libffi-dev libicu-dev libxml2-dev \
libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libxslt-dev autoconf pkg-config libssl-dev libmagickwand-dev
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version
RUN echo mailtrap > /etc/nullmailer/remotes

# install modules
RUN pecl install xdebug-3.1.6
RUN pecl install mongodb-1.15.0
RUN pecl install imagick-3.7.0
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr
RUN docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mysqli mbstring bcmath calendar exif fileinfo gettext intl soap xsl sockets zip
# other extensions we dont need right now
# mysqli pcntl hmop sockets sysvmsg sysvmsg sysvshm sysvsem ffi

RUN docker-php-ext-enable xdebug
RUN docker-php-ext-enable mongodb
RUN docker-php-ext-enable imagick

#ADD conf.d/xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

RUN cd /tmp \
	&& curl -o ioncube.tar.gz https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.2.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20170718/ioncube_loader_lin_7.2.so" > /usr/local/etc/php/conf.d/000-ioncube.ini

ADD run.sh /run.sh
RUN chmod +x /run.sh

#USER web
