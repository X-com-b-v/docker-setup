FROM nginx:stable

ADD nginx.conf /etc/nginx/nginx.conf
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD run.sh /run.sh

RUN apt-get update && apt-get -y install jq nano openssl sudo && \
    useradd -u 1000 -s /bin/bash web && \
    echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=NL/ST=Limburg/L=Maasbree/O=X-com B.V./OU=ICT/CN=devserver" && \
    chmod +x /run.sh

#CMD ["nginx", "-g", "daemon off;"]
CMD ["/run.sh"]
