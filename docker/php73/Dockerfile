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

#yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

#mssql stuff
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/debian/9/prod.list | tee /etc/apt/sources.list.d/microsoft.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php7.3-fpm php7.3-cli php7.3-mysql php7.3-gd php7.3-intl php7.3-curl php7.3-xsl php7.3-xdebug php7.3-mbstring php7.3-zip php7.3-soap php7.3-mongodb php7.3-bcmath php-imagick \
    build-essential git git-flow subversion bzip2 default-mysql-client nullmailer python toilet yarn openjdk-11-jre php7.3-dev dialog apt-utils unixodbc-dev rsync


#install sqlsrv for mssql
RUN ACCEPT_EULA=Y apt-get -y install msodbcsql17 mssql-tools && pecl install sqlsrv && pecl install pdo_sqlsrv

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.3/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.3/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 7.3 sqlsrv pdo_sqlsrv

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php7.3-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php7.3-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

COPY conf.d/xdebug.ini /etc/php/7.3/mods-available/

#RUN update-alternatives --set php /usr/bin/php7.3

USER web
WORKDIR /data/sites

CMD ["/run.sh"]

