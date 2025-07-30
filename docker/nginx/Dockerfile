# current nginx stable is 1.26.2
FROM nginx:stable

ADD nginx.conf /etc/nginx/nginx.conf
ADD fastcgi.conf /etc/nginx/fastcgi.conf
ADD run.sh /run.sh

RUN apt-get update && apt-get -y install jq nano openssl sudo && \
    useradd -u 1000 -s /bin/bash web && \
    echo 'web ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=NL/ST=Limburg/L=Maasbree/O=X-com B.V./OU=ICT/CN=devserver" && \
    chmod +x /run.sh


#### CUSTOM CONFIG FOR BROTLI, IN CASE YOU DO NOT WANT THIS OR THIS BREAKS IMAGE CREATION, PLEASE COMMENT BELOW LINES
# add brotli support
# first install all dependencies
RUN apt-get install -y wget git build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev libgd-dev libxml2 libxml2-dev uuid-dev libxslt-dev

# we need to fetch nginx source code again as it has to be recompiled, since we run 1.28.0 with current nginx stable, we fetch that
RUN cd ~ && wget https://nginx.org/download/nginx-1.28.0.tar.gz && \
    tar -xzvf nginx-1.28.0.tar.gz && \
    git clone https://github.com/google/ngx_brotli.git --recursive

# below configure arguments are fetched from Nginx's version 1.28.0 nginx -V
# and brotli is added
RUN cd ~/nginx-1.28.0 && chmod +x configure && \
    ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-g -O2 -ffile-prefix-map=/data/builder/debuild/nginx-1.28.0/debian/debuild-base/nginx-1.28.0=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' --with-compat --add-dynamic-module=../ngx_brotli
RUN cd ~/nginx-1.28.0 && make modules && \
    cp objs/ngx_http_brotli_filter_module.so /etc/nginx/modules && \
    cp objs/ngx_http_brotli_static_module.so /etc/nginx/modules

# cleanup
RUN rm -R ~/ngx_brotli ~/nginx-1.28.0*
#### END CUSTOM CONFIG FOR BROTLI, IN CASE YOU DO NOT WANT THIS OR THIS BREAKS IMAGE CREATION, PLEASE COMMENT ABOVE LINES

#CMD ["nginx", "-g", "daemon off;"]
CMD ["/run.sh"]
