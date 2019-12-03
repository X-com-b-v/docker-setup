FROM eaudeweb/mailtrap

RUN sed -i '/# mailtrap/a \nmynetworks = 0.0.0.0/0' /etc/postfix/main.cf

RUN sed -i 's/Listen 80/Listen 8085/' /etc/apache2/ports.conf

RUN sed -i 's/80/8085/' /etc/apache2/sites-available/000-default.conf
