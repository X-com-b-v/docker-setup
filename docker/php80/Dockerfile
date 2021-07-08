# default
FROM debian:buster

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget unzip zsh
RUN sed -i '/nl_NL/ s/^# //g' /etc/locale.gen && sed -i '/en_US/ s/^# //g' /etc/locale.gen && /usr/sbin/locale-gen
RUN useradd -u 1000 -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version

RUN sudo apt -y install lsb-release apt-transport-https ca-certificates 

#custom
RUN apt-get update && apt-get -y install apt-transport-https lsb-release ca-certificates gnupg
RUN wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

#yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php8.0-fpm php8.0-cli php8.0-mysql php8.0-gd php8.0-intl php8.0-curl php8.0-xsl php8.0-xdebug php8.0-mbstring php8.0-zip php8.0-soap php8.0-mongodb php8.0-bcmath php-imagick \
    build-essential git git-flow subversion bzip2 default-mysql-client nullmailer python yarn toilet openjdk-11-jre

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php8.0-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php8.0-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

COPY conf.d/xdebug.ini /etc/php/8.0/mods-available/

USER web
WORKDIR /data/sites

CMD ["/run.sh"]

