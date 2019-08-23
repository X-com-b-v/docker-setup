# default
FROM debian:stretch

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget
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
    apache2 libapache2-mod-php7.3 php7.3-cli php7.3-mysql php7.3-gd php7.3-intl php7.3-curl php7.3-xsl php7.3-xdebug php7.3-mbstring php7.3-zip php7.3-soap php7.3-mongodb php7.3-bcmath php-imagick \
    build-essential git git-flow subversion bzip2 mysql-client nullmailer python

RUN echo 127.1.0.1 > /etc/nullmailer/remotes


RUN a2enmod actions && a2enmod rewrite && a2enmod ssl

RUN rm /etc/apache2/sites-enabled/*
RUN sed -i 's/www-data/web/g' /etc/apache2/envvars

ADD ports.conf /etc/apache2/ports.conf


ADD run.sh /run.sh
RUN chmod +x /run.sh

WORKDIR /data/sites

CMD ["/run.sh"]

