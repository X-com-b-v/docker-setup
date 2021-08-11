FROM php:7.4.22-fpm-alpine3.14

RUN apk --no-cache update \
    && apk --no-cache upgrade \
    && apk add --no-cache --virtual \
        .build-deps \
        $PHPIZE_DEPS \
        gcc \
        g++ \
        autoconf \
        tar \
    && apk add --no-cache \
        libxslt-dev \
        tidyhtml-dev \
        net-snmp-dev \
        aspell-dev \
        freetds-dev \
        openldap-dev \
        gettext-dev \
        imap-dev \
        openssh \
        sudo \
        nano \
        make \
        shadow \
        libmcrypt-dev \
        gmp-dev \
        openssl \
        mariadb-client \
        curl \
        freetype \
        libpng \
        libjpeg-turbo \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        libzip-dev \
        bzip2-dev \
        postgresql-dev \
        supervisor \
        bash \
        nginx \
        pngquant \
        jpegoptim \
        zip \
        icu-dev \
        libxml2-dev \
        dcron \
        wget \
        rsync \
        ca-certificates \
        oniguruma-dev \
    && apk add nullmailer --update-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted \
    && phpModules=" \
            bcmath \
            bz2 \
            calendar \
            exif \
            gd \
            gettext \
            gmp \
            imap \
            intl \
            ldap \
            mysqli \
            pcntl \
            pdo_dblib \
            pdo_mysql \
            pdo_pgsql \
            pgsql \
            pspell \
            shmop \
            snmp \
            soap \
            sockets \
            sysvmsg \
            sysvsem \
            sysvshm \
            tidy \
            xsl \
            opcache \
        " \
    && NPROC=$(getconf _NPROCESSORS_ONLN) \
    && docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \
#    Install APCU
#    @see https://github.com/docker-library/php/issues/1029
    && mkdir -p /usr/src/php/ext/apcu  \
    && mkdir -p /usr/src/php/ext/amqp  \
    && mkdir -p /usr/src/php/ext/igbinary  \
    && mkdir -p /usr/src/php/ext/redis  \
    && curl -fsSL https://pecl.php.net/get/apcu | tar xvz -C "/usr/src/php/ext/apcu" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/amqp | tar xvz -C "/usr/src/php/ext/amqp" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/igbinary | tar xvz -C "/usr/src/php/ext/igbinary" --strip 1 \
    && curl -fsSL https://pecl.php.net/get/redis | tar xvz -C "/usr/src/php/ext/redis" --strip 1 \
    && docker-php-ext-install -j${NPROC} $phpModules \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && apk del --no-cache gcc g++ freetype-dev libpng-dev libjpeg-turbo-dev .build-deps \
    && adduser --uid 1000 --shell /bin/bash --disabled-password --gecos "" web \
    && echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers


COPY ./conf.d/*.ini $PHP_INI_DIR/conf.d/
ADD run.sh /run.sh
# ADD php.pool.d/php-fpm.conf /usr/local/etc/php-fpm.conf
ADD php.pool.d/www.conf /usr/local/etc/php-fpm.d/www.conf
ADD php.pool.d/zz-docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf

RUN echo 127.0.0.1 > /etc/nullmailer/remotes
RUN chmod +x /run.sh

USER web
WORKDIR /data/shared/sites

CMD ["/run.sh"]
