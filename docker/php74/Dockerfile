# default
FROM php:7.4-fpm-bullseye
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo nano nullmailer git git-flow lsb-release apt-transport-https ca-certificates toilet \
mariadb-client rsync
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y zlib1g-dev libpng-dev libonig-dev libffi-dev libicu-dev libxml2-dev \
libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libzip-dev libxslt-dev 
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version
RUN echo mailtrap > /etc/nullmailer/remotes

# install modules
RUN pecl install xdebug
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mbstring bcmath calendar exif ffi fileinfo gettext intl soap zip xsl sockets
# other extensions we dont need right now
# mysqli pcntl hmop sockets sysvmsg sysvmsg sysvshm sysvsem

RUN docker-php-ext-enable xdebug 

ADD conf.d/xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

ADD run.sh /run.sh
RUN chmod +x /run.sh

#USER web
