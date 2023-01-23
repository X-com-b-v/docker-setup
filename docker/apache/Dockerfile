FROM debian:bullseye-slim

# Main
RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    nano jq gnupg build-essential bzip2 software-properties-common libapache2-mod-fcgid apache2

RUN getent passwd 1000 || useradd -u 1000 -m -s /bin/bash web
ADD run.sh /run.sh

# Apache config
ADD files/apache2/ports.conf /etc/apache2/ports.conf
ADD files/apache2/custom.conf /etc/apache2/conf-available/custom.conf
RUN a2enconf custom
RUN a2enmod remoteip rewrite expires actions fcgid alias proxy proxy_fcgi

# Apache vars
RUN ["/bin/bash", "-c", "sed -i 's/www-data/web/g' /etc/apache2/envvars"]
RUN chmod +x /run.sh
CMD ["/run.sh"]
