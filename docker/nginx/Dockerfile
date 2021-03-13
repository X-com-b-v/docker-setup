# default
FROM debian:buster

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && apt-get -y upgrade && apt-get -y install curl nano locales sudo jq wget
RUN sed -i '/nl_NL/ s/^# //g' /etc/locale.gen && sed -i '/en_US/ s/^# //g' /etc/locale.gen && /usr/sbin/locale-gen
RUN useradd -u 1000 -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'Version 1.0.0' > /etc/xcom_docker_version

#custom
RUN apt-get -y install nginx

#RUN sed -i 's/user www-data;/user web;/g' /etc/nginx/nginx.conf

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=NL/ST=Limburg/L=Maasbree/O=X-com B.V./OU=ICT/CN=devserver"

ADD nginx.conf /etc/nginx/nginx.conf

ADD run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
