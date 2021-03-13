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

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    php7.1-fpm php7.1-cli php7.1-mysql php7.1-gd php7.1-intl php7.1-curl php7.1-mcrypt php7.1-xsl php7.1-xdebug php7.1-mbstring php7.1-zip php7.1-soap php7.1-ssh2 php7.1-bcmath php7.1-mongodb php-imagick \
    build-essential git git-flow subversion bzip2 default-mysql-client nullmailer python toilet

# oh-my-zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

RUN echo 127.0.0.1 > /etc/nullmailer/remotes

ADD run.sh /run.sh
RUN chmod +x /run.sh

RUN sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERUSER=`cat /etc/xcomuser`' /etc/init.d/php7.1-fpm && sed -i '/SCRIPTNAME.*$/aexport XCOM_SERVERTYPE=dev' /etc/init.d/php7.1-fpm
RUN sed -i 's/^;user_ini.cache_ttl.*/user_ini.cache_ttl=5/g' /etc/php/*/*/php.ini

COPY conf.d/xdebug.ini /etc/php/7.1/mods-available/

USER web
WORKDIR /data/sites

CMD ["/run.sh"]

