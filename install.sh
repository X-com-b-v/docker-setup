#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root, use sudo"
  exit
fi

if [ ! -f "/etc/xcomuser" ]; then
  echo "Creating /etc/xcomuser file"
  echo $SUDO_USER > /etc/xcomuser
fi

echo "Please enter the directory you want to install base to (without trailing slash)"
read installdir
echo "Installdir set to $installdir"

if [ ! -d $installdir ]; then
  mkdir -p $installdir
fi

if [ ! -f /usr/local/bin/enter ]; then
  cp dep/enter /usr/local/bin/enter
  chmod +x /usr/local/bin/enter
fi

if [ ! -f /usr/local/bin/devctl]; then
  cp dep/devctl /usr/local/bin/devctl
  sed -i -e sed -i -e 's:installdirectory:'"$installdir"':g' /usr/local/bin/devctl
  chmod +x /usr/local/bin/devctl
fi

## updates

echo "Running updates"
apt -qq update 
# apt -qq -y upgrade // a bit heavy, especially if there are packages you don't want to upgrade
# install docker dependencies
DEBIAN_FRONTEND=noninteractive apt -y -qq install curl git software-properties-common apt-transport-https gnupg-agent ca-certificates
# removed parted, xfsprogs, ntpdate
# exim does not come with ubuntu default install
#apt -y purge exim4 exim4-base exim4-config exim4-daemon-light && apt-get -y autoremove

## end updates

## docker and docker-compose


if [ ! -f /usr/bin/docker ] || [ ! -f /usr/local/bin/docker-compose ]; then
  echo "You have not downloaded docker or docker-compose."
  read -p "Do you want me to install both for you? [y/N] " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    if [ ! -f /usr/bin/docker && -n "$(uname -v | grep Ubuntu)" ]; then
      # not sure if this will work, untested
      echo "Installing docker"
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      apt-key fingerprint 0EBFCD88

      # eoan isn't supported yet
      if [ "$(lsb_release -cs)" = "eoan" ]; then
        RELEASE="disco"
      else
        RELEASE=$(lsb_release -cs)
      fi

      add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $RELEASE \
      stable"
      apt -qq update
      apt -y install docker-ce
    fi
    if [ ! -f /usr/local/bin/docker-compose ]; then
      echo "Installing docker-compose"
      curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    fi
  else
    echo "You can download both at:"
    echo "https://docs.docker.com/install/"
    echo "https://docs.docker.com/compose/install/"
    exit
  fi
fi

## end docker and docker-compose

## prepare paths

if [ ! -d "$installdir/data/shared/sites" ]; then
  mkdir -p $installdir/data/shared/sites
  #chown -R web.web $installdir/data/shared/sites
fi

if [ ! -d "$installdir/data/shared/sockets" ]; then
  mkdir -p $installdir/data/shared/sockets
fi

if [ ! -d "$installdir/data/home" ]; then
  mkdir -p $installdir/data/home
fi

read -p "[git hooks] Skip configurator versioning post-checkout / post-merge? [y/N] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
  SKIP_CONFIGURATOR=1
fi

paths=( "php56" "php70" "php71" "php72" "php73")
for path in "${paths[@]}"
do :
  if [ ! -d "$installdir/data/home/$path" ]; then
    cp -R /etc/skel $installdir/data/home/$path
  fi
  if ! grep -q "export TERM=xterm" $installdir/data/home/$path/.bashrc; then
    echo "export TERM=xterm" >> $installdir/data/home/$path/.bashrc
  fi
  if ! grep -q "\$HOME/bin" $installdir/data/home/$path/.bashrc; then
    echo "PATH=\$HOME/bin:\$PATH" >> $installdir/data/home/$path/.bashrc
  fi
  if [ $SKIP_CONFIGURATOR = "1" ]; then
    echo "export SKIP_CONFIGURATOR=1" >> $installdir/data/home/$path/.bashrc
  fi
  if [ ! -f "$installdir/data/home/$path/git-autocomplete.sh" ]; then
    cp dep/git-autocomplete.sh $installdir/data/home/$path/
    chmod +x $installdir/data/home/$path/git-autocomplete.sh
  fi
done

if [ ! -d "$installdir/docker" ]; then
  mkdir -p $installdir/docker
  cp -r ./docker/* $installdir/docker/
fi

## end prepare paths

## gitconfig

if [ ! -d "$installdir/docker/dependencies" ]; then
  mkdir -p $installdir/docker/dependencies
  cp ./dep/gitconfig $installdir/docker/dependencies/
fi

echo "[gitconfig] Please enter your name"
read name
sed -i -e 's:username:'"$name"':g' $installdir/docker/dependencies/gitconfig

echo "[gitconfig] Please enter your e-mail address"
read email
sed -i -e 's:user@email.com:'"$email"':g' $installdir/docker/dependencies/gitconfig

for path in "${paths[@]}"
do :
  cp $installdir/docker/dependencies/gitconfig $installdir/data/home/$path/.gitconfig
done

# cleanup as there's no need for this anymore
if [ -d "$installdir/docker/dependencies" ]; then
  rm -r $installdir/docker/dependencies
fi

## end gitconfig

## ssh

if [ -f "/home/$SUDO_USER/.ssh/id_rsa" ]; then
  read -p "Found ssh key at /home/$SUDO_USER/.ssh/id_rsa, do you want to copy this? [y/N] " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    for path in "${paths[@]}"
    do :
      if [ ! -d $installdir/data/home/$path/.ssh ]; then
        mkdir $installdir/data/home/$path/.ssh
      fi
      # also use ssh config if found
      if [ -f "/home/$SUDO_USER/.ssh/config" ]; then
        cp /home/$SUDO_USER/.ssh/config $installdir/data/home/$path/.ssh/
      fi
      cp /home/$SUDO_USER/.ssh/id_rsa $installdir/data/home/$path/.ssh/
      cp /home/$SUDO_USER/.ssh/id_rsa.pub $installdir/data/home/$path/.ssh/
      chmod 400 $installdir/data/home/$path/.ssh/*
    done
  fi
fi

## end ssh

## docker compose

# replace existing docker compose with new to update settings after a second install
cp ./docker/docker-compose.yml $installdir/docker/docker-compose.yml

read -p "Do you want docker containers to restart automatically? [y/N] " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sed -i -e 's/# restart: always/restart: always/g' $installdir/docker/docker-compose.yml
fi

if [ -f "$installdir/docker/docker-compose.yml" ]; then
  echo "Setting up correct values for docker-compose based on your given installdir"
  sed -i -e 's:installdirectory:'"$installdir"':g' $installdir/docker/docker-compose.yml
fi

## end docker compose

chown -R $SUDO_USER:$SUDO_USER $installdir/data/home/*
chown -R $SUDO_USER:$SUDO_USER $installdir/data/shared/sites

# set max_map_count for sonarqube
sysctl -w vm.max_map_count=262144

echo "Installation prepared"
echo "1: Change directory to $installdir/docker"
echo "2: run docker-compose up -d"
echo "3: get some coffee as this might take some time"