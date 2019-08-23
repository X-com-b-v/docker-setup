# default
FROM debian:stretch

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget
RUN sed -i '/nl_NL/ s/^# //g' /etc/locale.gen && sed -i '/en_US/ s/^# //g' /etc/locale.gen && /usr/sbin/locale-gen
RUN useradd -u 1000 -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version

#custom
RUN apt-get -y install apache2

RUN a2enmod proxy_fcgi && a2enmod actions && a2enmod rewrite && a2enmod ssl

RUN rm /etc/apache2/sites-enabled/*
RUN sed -i 's/www-data/web/g' /etc/apache2/envvars

ADD ports.conf /etc/apache2/ports.conf

ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
