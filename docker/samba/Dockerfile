FROM debian:bullseye-slim

RUN sed -i 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN useradd -u 1000 -s /bin/bash web
RUN apt-get update
RUN apt-get -y install samba
ADD smb.conf /etc/samba/smb.conf
ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD ["/run.sh"]
