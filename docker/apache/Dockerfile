FROM debian:bookworm-slim

# Main setup
RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list.d/debian.sources && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install \
    vim nano jq gnupg build-essential bzip2 software-properties-common \
    libapache2-mod-fcgid apache2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Add user
RUN getent passwd 1000 || useradd -u 1000 -m -s /bin/bash web

# Apache configuration
COPY files/apache2/ports.conf /etc/apache2/ports.conf
COPY files/apache2/custom.conf /etc/apache2/conf-available/custom.conf
RUN a2enconf custom && \
    a2enmod remoteip rewrite expires actions fcgid alias proxy proxy_fcgi

# Add scripts
RUN ["/bin/bash", "-c", "sed -i 's/www-data/web/g' /etc/apache2/envvars"]
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Default command
CMD ["/run.sh"]
