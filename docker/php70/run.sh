#!/bin/bash

XCOMUSER=`cat /etc/xcomuser`
export XCOM_SERVERUSER=$XCOMUSER
export XCOM_SERVERTYPE=dev

sudo /etc/init.d/nullmailer start
sudo /etc/init.d/php7.0-fpm start
sudo /etc/init.d/php7.0-fpm status

if [ $? -neq 0 ];then
  exit $?
fi

if ! grep -q "export XCOM_SERVERUSER" /home/web/.bashrc; then
  echo "export XCOM_SERVERTYPE=dev" >> /home/web/.bashrc
  echo "export XCOM_SERVERUSER=`cat /etc/xcomuser`" >> /home/web/.bashrc
fi


if [ ! -d "/home/web/bin" ]; then
  mkdir -p /home/web/bin
fi

if [ ! -f "/home/web/bin/composer" ]; then
  curl https://getcomposer.org/composer.phar -o /home/web/bin/composer
  chmod +x /home/web/bin/composer
fi

if [ ! -f "/home/web/bin/dep" ]; then
  curl http://deployer.org/deployer.phar -o /home/web/bin/dep
  chmod +x /home/web/bin/dep
fi

if [ ! -f "/home/web/bin/magerun" ]; then
  curl https://files.magerun.net/n98-magerun.phar -o /home/web/bin/magerun
  chmod +x /home/web/bin/magerun
fi

if [ ! -f "/home/web/bin/magerun2" ]; then
  curl https://files.magerun.net/n98-magerun2.phar -o /home/web/bin/magerun2
  chmod +x /home/web/bin/magerun2
fi

if [ ! -f "/home/web/bin/pestle" ]; then
  curl http://pestle.pulsestorm.net/pestle.phar -o /home/web/bin/pestle
  chmod +x /home/web/bin/pestle
fi

if [ ! -f "/home/web/bin/symfony" ]; then
  curl -LsS https://symfony.com/installer -o /home/web/bin/symfony
  chmod a+x /home/web/bin/symfony
fi

if [ ! -f "/home/web/bin/deb" ]; then
  curl -LsS http://deployer.org/deployer.phar -o /home/web/bin/dep
  chmod a+x /home/web/bin/dep
fi

if [ ! -d "/home/web/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash
fi

sudo tail -f /var/log/php7.0-fpm.log