# default
FROM debian:stretch

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget
RUN sed -i '/nl_NL/ s/^# //g' /etc/locale.gen && sed -i '/en_US/ s/^# //g' /etc/locale.gen && /usr/sbin/locale-gen
RUN useradd -u 1000 -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version

#custom
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php7.0-fpm php7.0-cli php7.0-mysql php7.0-gd php7.0-intl php7.0-curl php7.0-mcrypt php7.0-xsl php7.0-xdebug php7.0-mbstring php7.0-zip php7.0-soap php7.0-ssh2 php7.0-bcmath php7.0-mongodb php-imagick \
    build-essential git git-flow subversion bzip2 mysql-client nullmailer python

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php7.0-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php7.0-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

USER web
WORKDIR /data/sites

CMD ["/run.sh"]

