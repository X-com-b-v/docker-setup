#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
    dialog --title "Root" --msgbox 'Please run this file as root' 8 44
    clear
    exit 1
fi

CONFIGFILE="/home/$SUDO_USER/.config/docker-setup.config"
if [ -f "$CONFIGFILE" ]; then
    . $CONFIGFILE
fi

if [ ! -f "/etc/xcomuser" ]; then
    echo $SUDO_USER > /etc/xcomuser
fi

FIRSTRUN=1
originstalldir=
while [[ -z $originstalldir ]]; do
    exec 3>&1
    origdir="/home/$SUDO_USER/x-com"
    if [ ! -z "$installdir" ]; then
        origdir=$installdir
    fi
    originstalldir=$(dialog --inputbox "Full path to install directory \nLeave empty to use root /" 8 60 $origdir 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
        clear
        exit $exitcode
    fi
done

installdir=$(echo $originstalldir | sed 's:/*$::')

if [ -z "$installdir" ]; then
    installdir="/"
fi

if [ ! -d $installdir ] ; then
    mkdir -p $installdir
elif [ -d $installdir ] && [ $installdir != "/" ]; then
    #echo "Existing installation found, continue setup to update docker-compose file and other dependencies"
    # dialog --title "Existing installation" --msgbox "Existing installation found. Using previous config file for current values" 8 44
    FIRSTRUN=0
fi

setup_devctl () {
    cp dep/devctl /usr/local/bin/devctl
    cp dep/enter /usr/local/bin/enter
    sed -i -e 's:installdirectory:'"$installdir"':g' /usr/local/bin/devctl
    chmod +x /usr/local/bin/devctl
    chmod +x /usr/local/bin/enter
}

setup_gitconfig () {
    if [ ! -d "$installdir/docker/dependencies" ]; then
        mkdir -p $installdir/docker/dependencies
    fi
    cp ./dep/gitconfig $installdir/docker/dependencies/
    name=
    while [[ -z $name ]]; do
        exec 3>&1
        name=$(dialog --title "git config" --inputbox "Please enter your name" 6 60 2>&1 1>&3)
        exitcode=$?;
        exec 3>&-;
        # if [ ! $exitcode = "0" ]; then
        # clear
        # exit $exitcode
        # fi
    done
    sed -i -e 's:username:'"$name"':g' $installdir/docker/dependencies/gitconfig

    email=
    while [[ -z $email ]]; do
        exec 3>&1
        email=$(dialog --title "git config" --inputbox "Please enter your e-mail address" 6 60 2>&1 1>&3)
        exitcode=$?;
        exec 3>&-;
        # if [ ! $exitcode = "0" ]; then
        # clear
        # exit $exitcode
        # fi
    done
    sed -i -e 's:user@email.com:'"$email"':g' $installdir/docker/dependencies/gitconfig
    #for path in "${paths[@]}"
}

cleanup () {
    # cleanup as there's no need for this anymore
    if [ -d "$installdir/docker/dependencies" ]; then
        rm -r $installdir/docker/dependencies
    fi
}

cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
options=(preinstall "Preinstall packages" "off"    # any option can be set to default to "on"
         devctl "Setup devctl" "on"
         autostart "Start docker containers automatically" "$SETUP_RESTART"
         gitconfig "Configure gitconfig" "$SETUP_GITCONFIG"
         ssh "Copy ssh keys to selected php versions" "$SETUP_SSH"
         varnish "Use Varnish (Magento)" "$SETUP_VARNISH"
         configurator "Skip magento configurator" "$SKIP_CONFIGURATOR"
         xdebug "Enable Xdebug" "$SETUP_XDEBUG"
         xdebug-trigger "Trigger xdebug with request" "$SETUP_XDEBUG_TRIGGER"
)

# reset basic variables
SKIP_CONFIGURATOR=off
SETUP_GITCONFIG=off
SETUP_SSH=off
SETUP_RESTART=off
SETUP_XDEBUG=off
SETUP_VARNISH=off
SETUP_XDEBUG_TRIGGER=off

settings=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear
if [ -z "$settings" ]; then
    echo "No settings provided, or cancelled"
    exit 1
fi
for setting in $settings
do :
    case "$setting" in
        preinstall)
            apt update -qq
            DEBIAN_FRONTEND=noninteractive apt install curl git jq software-properties-common apt-transport-https gnupg-agent ca-certificates -y -qq
            ;;
        devctl)
            setup_devctl
            ;;
        configurator)
            SKIP_CONFIGURATOR=on
            ;;
        gitconfig)
            setup_gitconfig
            SETUP_GITCONFIG=on
            ;;
        ssh)
            SETUP_SSH=on
            ;;
        autostart)
            SETUP_RESTART=on
            ;;
        varnish)
            SETUP_VARNISH=on
            ;;
        xdebug)
            SETUP_XDEBUG=on
            ;;
        xdebug-trigger)
            SETUP_XDEBUG_TRIGGER=on
            ;;
        *)
            echo "No settings provided"
            exit 1;
            ;;
    esac        
done

## prepare paths
folders=( "$installdir/docker" "$installdir/data/shared/sites" "$installdir/data/shared/media" "$installdir/data/shared/sockets" "$installdir/data/home" "$installdir/data/elasticsearch" )
for folder in ${folders[@]}
do :
    if [ ! -d "$folder" ]; then
        mkdir -p $folder
    fi
done

# replace existing docker compose with new to update settings after a second install
cp ./docker/docker-compose.yml $installdir/docker/docker-compose.yml
cp ./docker/sonarqube.yml $installdir/docker/sonarqube.yml
# cp -r ./docker/* $installdir/docker/

if [ $SETUP_VARNISH == "on" ] && [ -f docker-compose-snippets/varnish ]; then
    sed -i -e 's/- 80:80/- 8080:80/g' $installdir/docker/docker-compose.yml
    cat docker-compose-snippets/varnish >> $installdir/docker/docker-compose.yml
fi

# make sure other services are not forgotten, these are not updated every run
services=( "mailtrap" "nginx" "mysql57" "mysql80" "elasticsearch" "varnish" )
for service in "${services[@]}"
do :
    if [ ! -d $installdir/docker/$service ]; then
        mkdir -p $installdir/docker/$service
    fi
    cp -r ./docker/$service/* $installdir/docker/$service
done

cmd=(dialog --separate-output --checklist "Select PHP versions:" 22 76 16)
options=(php56 "PHP 5.6" "$PHP56"    # any option can be set to default to "on"
         php70 "PHP 7.0" "$PHP70"
         php71 "PHP 7.1" "$PHP71"
         php72 "PHP 7.2" "$PHP72"
         php73 "PHP 7.3" "$PHP73"
         php74 "PHP 7.4" "$PHP74"
         php80 "PHP 8.0" "$PHP80"
         php81 "PHP 8.1" "$PHP81"
         )

# Reset PHP variables
PHP56=off
PHP70=off
PHP71=off
PHP72=off
PHP73=off
PHP74=off
PHP80=off
PHP81=off

paths=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

if [ -z "$paths" ]; then
    echo "No paths provided, or cancelled"
    exit 1
fi
for path in $paths
do :
    # use printf to assign php value 
    # https://stackoverflow.com/a/55331060
    printf -v "${path^^}" '%s' 'on'
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
    if [ $SKIP_CONFIGURATOR == "on" ]; then
        echo "export SKIP_CONFIGURATOR=1" >> $installdir/data/home/$path/.bashrc
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
    cp -r ./docker/$path $installdir/docker/

    if [[ ! -d $installdir/docker/$path/conf.d || ! -f $installdir/docker/$path/conf.d/xdebug.ini ]]; then
        mkdir -p $installdir/docker/$path/conf.d
    fi
    
    ## ssh
    if [ $SETUP_SSH == "on" ]; then 
        if [ -f "/home/$SUDO_USER/.ssh/id_rsa" ]; then
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
            
        fi
    fi
    ## end ssh

    # copy configs
    cp ./dep/xdebug.ini $installdir/docker/$path/conf.d/
    cp ./dep/opcache.ini $installdir/docker/$path/conf.d/

    if [ $SETUP_XDEBUG == "off" ]; then
        sed -i -e 's/xdebug.mode=debug,develop/;xdebug.mode=debug,develop/g' $installdir/docker/$path/conf.d/xdebug.ini
        sed -i -e 's/;xdebug.mode=off/xdebug.mode=off/g' $installdir/docker/$path/conf.d/xdebug.ini
    fi

    if [ $SETUP_XDEBUG_TRIGGER == "on" ]; then
        sed -i -e 's/xdebug.start_with_request=yes/;xdebug.start_with_request=yes/g' $installdir/docker/$path/conf.d/xdebug.ini
        sed -i -e 's/;xdebug.start_with_request=trigger/xdebug.start_with_request=trigger/g' $installdir/docker/$path/conf.d/xdebug.ini
    fi

    position=4
    phpversion="$path"
    phpversion="${phpversion:0:position}.${phpversion:position}"

    cp ./dep/phprun.sh $installdir/docker/$path/run.sh
    sed -i "s/##PHPVERSION##/$phpversion/g" $installdir/docker/$path/run.sh

    if [ $SETUP_GITCONFIG == "on" ]; then
        cp $installdir/docker/dependencies/gitconfig $installdir/data/home/$path/.gitconfig
    fi

done
## end prepare paths

if [ $SETUP_RESTART == "on" ]; then
    sed -i -e 's/# restart: always/restart: always/g' $installdir/docker/docker-compose.yml
fi

if [ -f "$installdir/docker/docker-compose.yml" ]; then
    #echo "Setting up correct values for docker-compose based on your given installdir"
    sed -i -e 's:installdirectory:'"$installdir"':g' $installdir/docker/docker-compose.yml
fi

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

# clear config file and write settings to it
echo installdir=$installdir > $CONFIGFILE
echo SKIP_CONFIGURATOR=$SKIP_CONFIGURATOR >> $CONFIGFILE
echo SETUP_GITCONFIG=$SETUP_GITCONFIG >> $CONFIGFILE
echo SETUP_SSH=$SETUP_SSH >> $CONFIGFILE
echo SETUP_RESTART=$SETUP_RESTART >> $CONFIGFILE
echo SETUP_XDEBUG=$SETUP_XDEBUG >> $CONFIGFILE
echo SETUP_VARNISH=$SETUP_VARNISH >> $CONFIGFILE
echo SETUP_XDEBUG_TRIGGER=$SETUP_XDEBUG_TRIGGER >> $CONFIGFILE

echo PHP56=$PHP56 >> $CONFIGFILE
echo PHP70=$PHP70 >> $CONFIGFILE
echo PHP71=$PHP71 >> $CONFIGFILE
echo PHP72=$PHP72 >> $CONFIGFILE
echo PHP73=$PHP73 >> $CONFIGFILE
echo PHP74=$PHP74 >> $CONFIGFILE
echo PHP80=$PHP80 >> $CONFIGFILE
echo PHP81=$PHP81 >> $CONFIGFILE
sudo chown $SUDO_USER:$SUDO_USER $CONFIGFILE

cleanup

dialog --title "Complete" --msgbox "Installation prepared \n 
Config is written to ~/.config/docker-setup.config\n
1: cd to $installdir\n
2: Run docker compose build\n
3: Get coffee\n
4: Run docker compose up -d\n
5: Get coffee\n
6: Run devctl up\n
" 13 53
clear
exit 0
