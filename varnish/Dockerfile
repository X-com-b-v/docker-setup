FROM debian:jessie

# Update the package repository and install applications
RUN apt-get update -qq && \
  apt-get upgrade -yqq && \
  apt-get -yqq install varnish && \
  apt-get -yqq clean

ENV VARNISH_BACKEND_PORT 81
ENV VARNISH_BACKEND_IP 127.0.0.1
ENV VARNISH_PORT 82

ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
