#!/usr/bin/env bash

XCOMUSER=`cat /etc/xcomuser`
export XCOM_SERVERUSER=$XCOMUSER
export XCOM_SERVERTYPE=dev

sudo /etc/init.d/nullmailer start

if [ $? -ne 0 ]; then
  exit $?
fi

if ! grep -q "export XCOM_SERVERUSER" /home/web/.bashrc; then
  echo "export XCOM_SERVERTYPE=dev" >> /home/web/.bashrc
  echo "export XCOM_SERVERUSER=`cat /etc/xcomuser`" >> /home/web/.bashrc
fi

echo "toilet -w 100 -F gay X-Com PHP" > /home/web/.toilet
if ! grep -q "source /home/web/.toilet" /home/web/.bashrc; then
  echo "source /home/web/.toilet" >> /home/web/.bashrc
fi

if [ ! -f "/home/web/.git-completion.bash" ]; then
  bash /home/web/git-autocomplete.sh
fi

BIN_DIR="/home/web/bin"
if [ ! -d "$BIN_DIR" ]; then
  mkdir -p $BIN_DIR
fi

declare -A array
array[composer]=https://getcomposer.org/composer.phar
array[dep]=http://deployer.org/deployer.phar
array[magerun]=https://files.magerun.net/n98-magerun.phar
array[magerun2]=https://files.magerun.net/n98-magerun2.phar
array[symfony]=https://symfony.com/installer
for i in "${!array[@]}"
do
    if [ ! -f "$BIN_DIR/$i" ]; then
        curl -LsS ${array[$i]} -o $BIN_DIR/$i
        chmod +x $BIN_DIR/$i
    fi
done

if [ ! -f "/home/web/bin/starship" ]; then
    sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir /home/web/bin --force
    echo 'eval "$(starship init bash)"' >> /home/web/.bashrc
fi

if [ ! -d "/home/web/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.2/install.sh | bash
fi

sudo php-fpm -R
