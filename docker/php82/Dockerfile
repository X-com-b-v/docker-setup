# default
FROM php:8.2-fpm-bullseye
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo nano nullmailer zlib1g-dev libpng-dev git git-flow libonig-dev libffi-dev libicu-dev libxml2-dev \
libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev lsb-release apt-transport-https ca-certificates libzip-dev libxslt-dev autoconf pkg-config libssl-dev libmagickwand-dev python2 python-is-python2 subversion build-essential gnupg2 unzip rsync mariadb-client
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo mailtrap > /etc/nullmailer/remotes

# install modules
RUN pecl install xdebug
RUN pecl install mongodb
RUN pecl install imagick
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mysqli mbstring bcmath calendar exif ffi fileinfo gettext intl soap zip xsl sockets
# other extensions we dont need right now
# mysqli pcntl hmop sockets sysvmsg sysvmsg sysvshm sysvsem

RUN docker-php-ext-enable xdebug 
RUN docker-php-ext-enable mongodb 
RUN docker-php-ext-enable imagick

ADD conf.d/xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

ADD run.sh /run.sh
RUN chmod +x /run.sh

#USER web
