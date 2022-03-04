FROM php:7.3-fpm-bullseye
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo nano nullmailer zlib1g-dev libpng-dev git git-flow libonig-dev libffi-dev libicu-dev libxml2-dev \
libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev lsb-release apt-transport-https ca-certificates 
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version
RUN echo mailtrap > /etc/nullmailer/remotes

# install modules
RUN pecl install xdebug
RUN docker-php-ext-configure gd --with-freetype-dir=/usr --with-jpeg-dir=/usr --with-png-dir=/usr
RUN docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mbstring bcmath calendar exif fileinfo gettext intl soap
# other extensions we dont need right now
# mysqli pcntl hmop sockets sysvmsg sysvmsg sysvshm sysvsem ffi

RUN docker-php-ext-enable xdebug 

ADD conf.d/opcache.ini "$PHP_INI_DIR/conf.d/opcache.ini"
ADD conf.d/xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"

ADD run.sh /run.sh
RUN chmod +x /run.sh

#USER web
