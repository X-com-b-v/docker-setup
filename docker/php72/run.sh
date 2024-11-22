#!/usr/bin/env bash
set -e

CONFIGFILE="/etc/docker-setup.config"
USERNAME=
HOME_DIR="/home/web"
BIN_DIR="$HOME_DIR/bin"

# Laad configuratiebestand, indien aanwezig
if [ -f "$CONFIGFILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIGFILE"
fi

# Stel omgevingsvariabelen in
export XCOM_SERVERUSER=$USERNAME
export XCOM_SERVERTYPE=dev

# Start nullmailer-service
sudo /etc/init.d/nullmailer start

# Stel gebruikersomgeving in, indien niet aanwezig
if [ ! -f "$HOME_DIR/.bashrc" ]; then
    cp -R /etc/skel/. "$HOME_DIR/"
    echo "alias m2='magerun2'" >> "$HOME_DIR/.bash_aliases"
    echo "alias ls='ls --color=auto -lrth --group-directories-first'" >> "$HOME_DIR/.bash_aliases"
fi

# Creëer bin-map en update pad
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
    if ! grep -q "\$HOME/bin" "$HOME_DIR/.bashrc"; then
        echo "PATH=\$HOME/bin:\$PATH" >> "$HOME_DIR/.bashrc"
    fi
fi

# Voeg omgevingsvariabelen toe aan .bashrc
if ! grep -q "export XCOM_SERVERUSER" "$HOME_DIR/.bashrc"; then
    {
        echo "export XCOM_SERVERTYPE=$XCOM_SERVERTYPE"
        echo "export XCOM_SERVERUSER=$XCOM_SERVERUSER"
    } >> "$HOME_DIR/.bashrc"
fi

# Stel terminaltype in
if ! grep -q "export TERM=xterm" "$HOME_DIR/.bashrc"; then
    echo "export TERM=xterm" >> "$HOME_DIR/.bashrc"
fi

# Git-autocomplete instellen
if [ ! -f "$HOME_DIR/.git-completion.bash" ]; then
    bash "$HOME_DIR/git-autocomplete.sh"
fi

# Download tools indien nodig
declare -A tools=(
    [composer]="https://getcomposer.org/composer.phar"
    [dep]="http://deployer.org/deployer.phar"
    [magerun]="https://files.magerun.net/n98-magerun.phar"
    [magerun2]="https://files.magerun.net/n98-magerun2.phar"
    [symfony]="https://symfony.com/installer"
)

for tool in "${!tools[@]}"; do
    if [ ! -f "$BIN_DIR/$tool" ]; then
        curl -LsS "${tools[$tool]}" -o "$BIN_DIR/$tool"
        chmod +x "$BIN_DIR/$tool"
    fi
done

# Starship configureren
STARSHIP_FILE="$HOME_DIR/.starship"
echo '' > "$STARSHIP_FILE"
if [ "$SETUP_STARSHIP" == "on" ]; then
    if [ ! -f "$BIN_DIR/starship" ]; then
        sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --bin-dir "$BIN_DIR" --force
    fi
    echo 'eval "$(starship init bash)"' > "$STARSHIP_FILE"
fi
if ! grep -q "source $STARSHIP_FILE" "$HOME_DIR/.bashrc"; then
    echo "source $STARSHIP_FILE" >> "$HOME_DIR/.bashrc"
fi

# Installeer NVM indien nodig
if [ ! -d "$HOME_DIR/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi

# Start PHP-FPM
sudo php-fpm -R
