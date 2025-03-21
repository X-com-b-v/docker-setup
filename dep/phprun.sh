#!/usr/bin/env bash

CONFIGFILE="/etc/docker-setup.config"
USERNAME=
if [ -f "$CONFIGFILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIGFILE"
fi
export XCOM_SERVERUSER=$USERNAME
export XCOM_SERVERTYPE=dev

sudo /etc/init.d/nullmailer start

if [ ! -f "/home/web/.bashrc" ]; then
    cp -R /etc/skel/. /home/web/
    echo "alias m2='magerun2'" >> /home/web/.bash_aliases
    echo "alias ls='ls --color=auto -lrth --group-directories-first'" >> /home/web/.bash_aliases
fi

BIN_DIR="/home/web/bin"
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p $BIN_DIR
    if ! grep -q "\$HOME/bin" /home/web/.bashrc; then
        echo "PATH=\$HOME/bin:\$PATH" >> /home/web/.bashrc
    fi
fi

if ! grep -q "export XCOM_SERVERUSER" /home/web/.bashrc; then
  echo "export XCOM_SERVERTYPE=$XCOM_SERVERTYPE" >> /home/web/.bashrc
  echo "export XCOM_SERVERUSER=$XCOM_SERVERUSER" >> /home/web/.bashrc
fi

if ! grep -q "export TERM=xterm" /home/web/.bashrc; then
    echo "export TERM=xterm" >> /home/web/.bashrc
fi

if [ ! -f "/home/web/.git-completion.bash" ]; then
  bash /home/web/git-autocomplete.sh
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
        curl -LsS "${array[$i]}" -o "$BIN_DIR"/"$i"
        chmod +x "$BIN_DIR"/"$i"
    fi
done

echo '' > /home/web/.starship
if [ "$SETUP_STARSHIP" == "on" ]; then
    if [ ! -f "/home/web/bin/starship" ]; then
        sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir /home/web/bin --force
    fi
    # shellcheck disable=SC2016
    echo 'eval "$(starship init bash)"' > /home/web/.starship
fi
if ! grep -q "source /home/web/.starship" /home/web/.bashrc; then
  echo "source /home/web/.starship" >> /home/web/.bashrc
fi

if [ ! -d "/home/web/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

sudo php-fpm -R
