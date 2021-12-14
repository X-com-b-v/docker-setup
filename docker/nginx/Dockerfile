FROM alpine:3.14

ADD nginx.conf /etc/nginx/nginx.conf
ADD run.sh /run.sh

RUN apk update
RUN apk add --no-cache openrc bash nginx jq nano openssl sudo && \
    adduser --uid 1000 --shell /bin/bash --disabled-password --gecos "" web && \
    echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    mkdir -p /etc/nginx/sites-enabled/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=NL/ST=Limburg/L=Maasbree/O=X-com B.V./OU=ICT/CN=devserver" && \
    chmod +x /run.sh && \
    openrc && \
    touch /run/openrc/softlevel

RUN mkdir -p /var/lib/nginx/tmp /var/log/nginx \
    && chown -R web:web /var/lib/nginx /var/log/nginx \
    && chmod -R 755 /var/lib/nginx /var/log/nginx

#CMD ["nginx", "-g", "daemon off;"]
CMD ["/run.sh"]
