FROM debian:bullseye

# Main
RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
    curl nano locales sudo jq wget apt-transport-https lsb-release ca-certificates gnupg \
    build-essential git git-flow subversion bzip2 nullmailer python software-properties-common libapache2-mod-fcgid \ 
    apache2

RUN getent passwd 1000 || useradd -u 1000 -m -s /bin/bash web
RUN echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
ADD run.sh /run.sh

# Apache config
ADD files/apache2/ports.conf /etc/apache2/ports.conf
ADD files/apache2/custom.conf /etc/apache2/conf-available/custom.conf
#RUN mkdir /etc/apache2/snippets
#RUN ["/bin/bash", "-c", "cp /etc/apache2/conf-available/php* /etc/apache2/snippets/"]
RUN a2enconf custom
RUN a2enmod remoteip rewrite expires actions fcgid alias proxy proxy_fcgi

# Apache vars
RUN ["/bin/bash", "-c", "sed -i 's/www-data/web/g' /etc/apache2/envvars"]
RUN chmod +x /run.sh
CMD ["/run.sh"]
