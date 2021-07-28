#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    dialog --title "Root" --msgbox 'Please run this file as root' 8 44
    clear
    exit 1
fi

if [ ! -f "/etc/xcomuser" ]; then
    echo $SUDO_USER > /etc/xcomuser
fi

if dialog --stdout --title "Preinstall some necessary packages?" \
            --backtitle "Packages" \
            --yesno "Will run apt update and install basic packages \n\n
curl git software-properties-common apt-transport-https gnupg-agent ca-certificates" 10 60; then
    apt update -qq
    DEBIAN_FRONTEND=noninteractive apt install curl git jq software-properties-common apt-transport-https gnupg-agent ca-certificates -y -qq
fi

FIRSTRUN=1
originstalldir=
while [[ -z $originstalldir ]]; do
    exec 3>&1
    originstalldir=$(dialog --inputbox "Full path to install directory" 8 60 /home/$SUDO_USER/x-com 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
        clear
        exit $exitcode
    fi
done

installdir=$(echo $originstalldir | sed 's:/*$::')

if [ ! -d $installdir ]; then
    mkdir -p $installdir
else
    #echo "Existing installation found, continue setup to update docker-compose file and other dependencies"
    dialog --title "Existing installation" --msgbox "Existing installation found, continuing with overrides" 8 44
    FIRSTRUN=0
fi

if [ ! -f /usr/local/bin/devctl ]; then
    cp dep/devctl /usr/local/bin/devctl
    cp dep/enter /usr/local/bin/enter
    sed -i -e 's:installdirectory:'"$installdir"':g' /usr/local/bin/devctl
    chmod +x /usr/local/bin/devctl
    chmod +x /usr/local/bin/enter
else
    if dialog --stdout --title "devctl found, overwrite?" \
            --backtitle "devctl" \
            --yesno "Found devctl, want to overwrite existing with new parameters?" 10 60; 
    then
        cp dep/devctl /usr/local/bin/devctl
        cp dep/enter /usr/local/bin/enter
        sed -i -e 's:installdirectory:'"$installdir"':g' /usr/local/bin/devctl
        chmod +x /usr/local/bin/devctl
        chmod +x /usr/local/bin/enter
    fi
fi

## docker and docker-compose

if [ ! -f /usr/bin/docker ] && [[ ! -f /usr/local/bin/docker-compose || ! -f /usr/local/docker-compose ]]; then
    if dialog --stdout --title "Docker and docker-compose missing" \
            --backtitle "docker & docker-compose" \
            --defaultno \
            --yesno "Tries to install docker and docker-compose for you, it is not properly tested" 7 60; then
        #dialog --title "Information" --msgbox "TRUE" 6 44
        if [[ ! -f /usr/bin/docker && -n "$(uname -v | grep Ubuntu)" ]]; then
            # not sure if this will work, untested
            #echo "Installing docker"
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            apt-key fingerprint 0EBFCD88
            #RELEASE=$(lsb_release -cs)
            RELEASE=focal
            add-apt-repository \
                "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                $RELEASE \
                stable"
            apt update -qq
            apt install docker-ce -y
        fi
        if [ ! -f /usr/local/bin/docker-compose ]; then
            echo "Installing docker-compose"
            curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            chmod +x /usr/local/bin/docker-compose
        fi
    else
        dialog --title "Information" --msgbox "You can download both at \n https://docs.docker.com/install/ \n https://docs.docker.com/compose/install/" 7 50
    fi
fi
## end docker and docker-compose

## prepare paths

if [ ! -d "$installdir/data/shared/sites" ]; then
    mkdir -p $installdir/data/shared/sites
    #chown -R web.web $installdir/data/shared/sites
fi

if [ ! -d "$installdir/data/shared/media" ]; then
  mkdir -p $installdir/data/shared/media
  #chown -R web.web $installdir/data/shared/media
fi

if [ ! -d "$installdir/data/shared/sockets" ]; then
    mkdir -p $installdir/data/shared/sockets
fi

if [ ! -d "$installdir/data/home" ]; then
    mkdir -p $installdir/data/home
fi

if dialog --stdout --title "Skip configurator versioning post-checkout / post-merge?" \
            --backtitle "git hooks" \
            --yesno "Will not execute magento configurator" 7 60; then
    SKIP_CONFIGURATOR=1
fi

if [ ! -d "$installdir/docker" ]; then
    mkdir -p $installdir/docker
fi
# replace existing docker compose with new to update settings after a second install
cp ./docker/docker-compose.yml $installdir/docker/docker-compose.yml
cp ./docker/sonarqube.yml $installdir/docker/sonarqube.yml
# cp -r ./docker/* $installdir/docker/

# make sure other services are not forgotten, these are not updated for a second run
services=( "mailtrap" "nginx" "mysql57" "mysql80" "elasticsearch6" "elasticsearch7" )
for service in "${services[@]}"
do :
    if [ ! -d $installdir/docker/$service ]; then
        cp -r ./docker/$service $installdir/docker/$service
    fi
done

cmd=(dialog --separate-output --checklist "Select PHP versions:" 22 76 16)
options=(php56 "PHP 5.6" off    # any option can be set to default to "on"
         php70 "PHP 7.0" off
         php71 "PHP 7.1" off
         php72 "PHP 7.2" on
         php73 "PHP 7.3" on
         php74 "PHP 7.4" on
         php80 "PHP 8.0" off)
paths=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
    #for path in "${paths[@]}"
    for path in $paths
    do :
    if [ ! -d "$installdir/data/home/$path" ]; then
        mkdir -p "$installdir/data/home/$path"
        cp -R /etc/skel/. $installdir/data/home/$path
        echo "alias m2='magerun2'" >> $installdir/data/home/$path/.bash_aliases
        echo "alias ls='ls --color=auto -lrth --group-directories-first'" >> $installdir/data/home/$path/.bash_aliases
    fi

    # give me a fresh bashrc --and zshrc file--
    #cp /etc/skel/.bashrc $installdir/data/home/$path
    #cp dep/zshrc $installdir/data/home/$path/.zshrc
    
    if ! grep -q "export TERM=xterm" $installdir/data/home/$path/.bashrc; then
        echo "export TERM=xterm" >> $installdir/data/home/$path/.bashrc
    fi
    if ! grep -q "\$HOME/bin" $installdir/data/home/$path/.bashrc; then
        echo "PATH=\$HOME/bin:\$PATH" >> $installdir/data/home/$path/.bashrc
    fi
    if grep -q "SKIP_CONFIGURATOR" $installdir/data/home/$path/.bashrc; then
        sed -i '/SKIP_CONFIGURATOR/d' $installdir/data/home/$path/.bashrc
    fi
    if [ $SKIP_CONFIGURATOR = "1" ]; then
        echo "export SKIP_CONFIGURATOR=1" >> $installdir/data/home/$path/.bashrc
        #echo "export SKIP_CONFIGURATOR=1" >> $installdir/data/home/$path/.zshrc
    fi
    if [ ! -f "$installdir/data/home/$path/git-autocomplete.sh" ]; then
        cp dep/git-autocomplete.sh $installdir/data/home/$path/
        chmod +x $installdir/data/home/$path/git-autocomplete.sh
    fi
    if [ ! -d "$installdir/data/home/$path/bin" ]; then
        mkdir -p "$installdir/data/home/$path/bin"
    fi
    if [ -f docker-compose-snippets/$path ]; then
        cat docker-compose-snippets/$path >> $installdir/docker/docker-compose.yml
    fi
    if [ ! -d $installdir/docker/$path ]; then
        cp -r ./docker/$path $installdir/docker/
    fi
    done
## end prepare paths

## gitconfig
if dialog --stdout --title "Configure gitconfig options?" \
            --backtitle "git config" \
            --yesno "Gitconfig containing aliases, makes life easy" 7 60; then
if [ ! -d "$installdir/docker/dependencies" ]; then
    mkdir -p $installdir/docker/dependencies
    cp ./dep/gitconfig $installdir/docker/dependencies/
fi
name=
while [[ -z $name ]]; do
    exec 3>&1
    name=$(dialog --title "git config" --inputbox "Please enter your name" 6 60 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
    clear
    exit $exitcode
    fi
done
sed -i -e 's:username:'"$name"':g' $installdir/docker/dependencies/gitconfig

email=
while [[ -z $email ]]; do
    exec 3>&1
    email=$(dialog --title "git config" --inputbox "Please enter your e-mail address" 6 60 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
    clear
    exit $exitcode
    fi
done
sed -i -e 's:user@email.com:'"$email"':g' $installdir/docker/dependencies/gitconfig
#for path in "${paths[@]}"
for path in $paths:
do :
    cp $installdir/docker/dependencies/gitconfig $installdir/data/home/$path/.gitconfig
done

# cleanup as there's no need for this anymore
if [ -d "$installdir/docker/dependencies" ]; then
    rm -r $installdir/docker/dependencies
fi
fi
## end gitconfig

## ssh
if [ -f "/home/$SUDO_USER/.ssh/id_rsa" ]; then
    if dialog --stdout --title "Use ssh /home/$SUDO_USER/.ssh/id_rsa?" \
                --backtitle "ssh" \
                --yesno "Copy ssh keys to each selected php container? \n
    $paths" 7 60; then
        #for path in "${paths[@]}"
        for path in $paths
        do :
        echo $path
        if [ ! -d $installdir/data/home/$path/.ssh ]; then
            mkdir $installdir/data/home/$path/.ssh
        fi
        # also use ssh config if found
        if [ -f "/home/$SUDO_USER/.ssh/config" ]; then
            cp /home/$SUDO_USER/.ssh/config $installdir/data/home/$path/.ssh/
        fi
        if [ -d "/home/$SUDO_USER/.ssh/X-com" ]; then
            cp -r /home/$SUDO_USER/.ssh/X-com $installdir/data/home/$path/.ssh/
        fi
        cp /home/$SUDO_USER/.ssh/id_rsa $installdir/data/home/$path/.ssh/
        cp /home/$SUDO_USER/.ssh/id_rsa.pub $installdir/data/home/$path/.ssh/
        # chmod -r 400 $installdir/data/home/$path/.ssh/*
        done
    fi
fi
## end ssh

## docker compose
if dialog --stdout --title "Do you want docker containers to restart automatically" \
            --backtitle "auto restart" \
            --defaultno \
            --yesno "Will automatically start containers on system boot. Very annoying." 7 60; then
    sed -i -e 's/# restart: always/restart: always/g' $installdir/docker/docker-compose.yml
fi

if [ -f "$installdir/docker/docker-compose.yml" ]; then
    #echo "Setting up correct values for docker-compose based on your given installdir"
    sed -i -e 's:installdirectory:'"$installdir"':g' $installdir/docker/docker-compose.yml
fi
## end docker compose

chown $SUDO_USER:$SUDO_USER $installdir
chown $SUDO_USER:$SUDO_USER $installdir/data/shared/sites
chown -R $SUDO_USER:$SUDO_USER $installdir/data/home/*
chown -R $SUDO_USER:$SUDO_USER $installdir/docker

if [ ! $FIRSTRUN = "0" ]; then
    # set max_map_count for sonarqube
    # sysctl -w vm.max_map_count=262144
    # make it permanent
    echo "vm.max_map_count=262144" > /etc/sysctl.d/sonarqube.conf
    echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf
    sysctl -p --system
fi

dialog --title "Complete" --msgbox "Installation prepared \n 
1: Run devctl build\n
2: Get coffee\n
3: Run devctl up\n
4: Get coffee\n
" 9 53
clear
exit 0
