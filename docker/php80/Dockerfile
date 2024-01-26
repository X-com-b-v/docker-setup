# default
FROM php:8.0-fpm-bullseye
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo nano nullmailer git git-flow lsb-release apt-transport-https ca-certificates \
mariadb-client rsync
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g-dev libpng-dev libonig-dev libffi-dev libicu-dev libxml2-dev \
libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libxslt-dev autoconf pkg-config libssl-dev libmagickwand-dev \
python2 python-is-python2 subversion build-essential gnupg2 unzip
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
