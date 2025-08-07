# default
FROM php:8.4-fpm-bookworm
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y apt-utils sudo vim nano nullmailer zlib1g-dev libpng-dev \
    git git-flow libonig-dev libffi-dev libicu-dev libxml2-dev libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev \
    libpng-dev lsb-release apt-transport-https ca-certificates libzip-dev libxslt-dev autoconf pkg-config libssl-dev \
    libmagickwand-dev python3 python-is-python3 subversion build-essential gnupg2 unzip rsync mariadb-client unixodbc \
    unixodbc-dev odbcinst odbcinst1debian2 libodbc1 libpcre3-dev
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo mailtrap > /etc/nullmailer/remotes

# mssql stuff
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/debian/12/prod bookworm main" > /etc/apt/sources.list.d/mssql-release.list
RUN sudo apt-get update
RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql18 mssql-tools18

# install modules
RUN pecl install xdebug
RUN pecl install mongodb
RUN pecl install imagick
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd opcache pdo_mysql mysqli mbstring bcmath calendar exif ffi fileinfo gettext \
    intl soap zip xsl sockets ftp
# other extensions we dont need right now
# mysqli pcntl hmop sockets sysvmsg sysvmsg sysvshm sysvsem

# mssql stuff
RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv

RUN docker-php-ext-enable xdebug
RUN docker-php-ext-enable mongodb
RUN docker-php-ext-enable imagick

# Use pecl to get Redis extension ready
RUN pecl install redis \
   # Redis is installed, enable it
    && docker-php-ext-enable redis

# Detect architecture and download correct AWS CLI installer
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$ARCH" = "aarch64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    unzip awscliv2.zip && ./aws/install && \
    rm -rf awscliv2.zip aws

ADD conf.d/xdebug.ini "$PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini"
ADD conf.d/sqlsrv.ini "$PHP_INI_DIR/conf.d/sqlsrv.ini"
ADD conf.d/pdo_sqlsrv.ini "$PHP_INI_DIR/conf.d/pdo_sqlsrv.ini"

ADD run.sh /run.sh
RUN chmod +x /run.sh

#USER web
