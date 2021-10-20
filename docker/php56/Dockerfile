# default
FROM debian:bullseye-slim

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

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php5.6-fpm php5.6-cli php5.6-mysql php5.6-gd php5.6-intl php5.6-curl php5.6-xsl php5.6-mbstring php5.6-zip php5.6-soap php-imagick \
    build-essential git git-flow subversion bzip2 default-mysql-client nullmailer python toilet rsync

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php5.6-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php5.6-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

USER web
WORKDIR /data/sites

CMD ["/run.sh"]
