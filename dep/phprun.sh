#!/usr/bin/env bash

CONFIGFILE="/etc/docker-setup.config"
USERNAME=
if [ -f "$CONFIGFILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIGFILE"
fi
export XCOM_SERVERUSER=$USERNAME
export XCOM_SERVERTYPE=dev

NPM_TOKENS_FILE="/etc/npm-tokens.env"
if [ -f "$NPM_TOKENS_FILE" ]; then
    set -a
    # shellcheck disable=SC1090
    . "$NPM_TOKENS_FILE"
    set +a
fi

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

# install docker CLI for container-side devctl (uses mounted Docker socket)
if [ ! -f "$BIN_DIR/docker" ]; then
    ARCH=$(uname -m)
    DOCKER_ARCH="x86_64"
    [ "$ARCH" = "aarch64" ] && DOCKER_ARCH="aarch64"
    curl -fsSL "https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-27.5.1.tgz" \
        | tar -xz -C "$BIN_DIR" --strip-components=1 docker/docker
fi

# install container-side devctl wrapper
if [ ! -f /usr/local/bin/devctl ]; then
    sudo cp /etc/devctl-container.sh /usr/local/bin/devctl
    sudo chmod +x /usr/local/bin/devctl
fi

if ! grep -q "export XCOM_SERVERUSER" /home/web/.bashrc; then
  echo "export XCOM_SERVERTYPE=$XCOM_SERVERTYPE" >> /home/web/.bashrc
  echo "export XCOM_SERVERUSER=$XCOM_SERVERUSER" >> /home/web/.bashrc
fi

if ! grep -q "npm-tokens.env" /home/web/.bashrc; then
    echo "if [ -f $NPM_TOKENS_FILE ]; then set -a; source $NPM_TOKENS_FILE; set +a; fi" >> /home/web/.bashrc
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

# Install Node.js LTS for Claude Code (persistent — /home/web is a bind mount)
NODE_DIR="/home/web/.node_lts"
if [ ! -f "$NODE_DIR/bin/node" ]; then
    ARCH=$(uname -m)
    NODE_ARCH="x64"
    [ "$ARCH" = "aarch64" ] && NODE_ARCH="arm64"
    curl -fsSL "https://nodejs.org/dist/v22.15.0/node-v22.15.0-linux-${NODE_ARCH}.tar.xz" \
        | tar -xJ -C "/home/web" --one-top-level=.node_lts --strip-components=1
    chown -R web:web "$NODE_DIR"
    if ! grep -q ".node_lts/bin" /home/web/.bashrc; then
        echo 'export PATH=$HOME/.node_lts/bin:$PATH' >> /home/web/.bashrc
    fi
fi
if [ -f "$NODE_DIR/bin/npm" ] && [ ! -f "$NODE_DIR/bin/claude" ]; then
    export PATH="$NODE_DIR/bin:$PATH"
    "$NODE_DIR/bin/npm" install -g @anthropic-ai/claude-code --prefix "$NODE_DIR"
    chown -R web:web "$NODE_DIR"
fi

sudo php-fpm -R
