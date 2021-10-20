# default
FROM debian:buster

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget unzip zsh
RUN sed -i '/nl_NL/ s/^# //g' /etc/locale.gen && sed -i '/en_US/ s/^# //g' /etc/locale.gen && /usr/sbin/locale-gen
RUN useradd -u 1000 -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version

#custom
RUN apt-get update && apt-get -y install apt-transport-https lsb-release ca-certificates gnupg
RUN wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
RUN apt-get -y install binutils-multiarch libodbc1 odbcinst1debian2 unixodbc-dev

#yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

#mssql stuff
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list | tee /etc/apt/sources.list.d/microsoft.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php7.2-fpm php7.2-cli php7.2-mysql php7.2-gd php7.2-intl php7.2-curl php7.2-xsl php7.2-xdebug php7.2-mbstring php7.2-zip php7.2-soap php7.2-ssh2 php7.2-mongodb php7.2-bcmath php-imagick \
    build-essential git git-flow subversion bzip2 default-mysql-client nullmailer python toilet openjdk-11-jre php7.2-dev yarn dialog apt-utils rsync

#install sqlsrv for mssql
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17 mssql-tools && pecl install sqlsrv-5.8.1 && pecl install pdo_sqlsrv-5.8.1

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.2/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 7.2 sqlsrv pdo_sqlsrv

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php7.2-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php7.2-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

COPY conf.d/xdebug.ini /etc/php/7.2/mods-available/

USER web
WORKDIR /data/sites

CMD ["/run.sh"]

