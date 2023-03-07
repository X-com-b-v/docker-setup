#!/usr/bin/env bash

# if [ "$EUID" -ne 0 ]; then
#     dialog --title "Root" --msgbox 'Please run this file as root' 8 44
#     clear
#     exit 1
# fi

CONFIGFILE="/home/$USER/.config/docker-setup.config"
if [ -f "$CONFIGFILE" ]; then
    . $CONFIGFILE
fi

while [[ -z $USERNAME ]]; do
    exec 3>&1
    USERNAME=$(dialog --title "username" --inputbox "Enter your username" 6 60 $USERNAME 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
done

FIRSTRUN=1
originstalldir=
while [[ -z $originstalldir ]]; do
    exec 3>&1
    origdir="/home/$USER/x-com"
    if [ ! -z "$installdir" ]; then
        origdir=$installdir
    fi
    originstalldir=$(dialog --inputbox "Full path to install directory \n" 8 60 $origdir 2>&1 1>&3)
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

# create installdir if it does not exist
if [ ! -d $installdir ] ; then
    mkdir -p $installdir
elif [ -d $installdir ]; then
    FIRSTRUN=0
fi

if [ ! -d "/home/$USER/.ssh" ] ; then
    mkdir -p "/home/$USER/.ssh"
fi

setup_devctl () {
    cp dep/devctl ~/.local/bin/devctl
    cp dep/enter ~/.local/bin/enter
    sed -i -e 's:installdirectory:'"$installdir"':g' ~/.local/bin/devctl
    chmod +x ~/.local/bin/devctl
    chmod +x ~/.local/bin/enter
}

setup_gitconfig () {
    if [ ! -d "$installdir/docker/dependencies" ]; then
        mkdir -p $installdir/docker/dependencies
    fi
    cp ./dep/gitconfig $installdir/docker/dependencies/
    name=$USER
    email=
    # open fd
    exec 3>&1
    dialog --separate-widget $'\n' --ok-label "Submit" \
        --backtitle "Gitconfig" \
        --title "Gitconfig" \
        --form "Add user information" \
    15 50 0 \
        "Name   :" 1 1	"$name" 	1 10 39 0 \
        "E-mail :"    2 1	"$email"  	2 10 40 0 \
    2>&1 1>&3 | { 
        read -r name
        read -r email
        sed -i -e 's:username:'"$name"':g' $installdir/docker/dependencies/gitconfig
        sed -i -e 's:user@email.com:'"$email"':g' $installdir/docker/dependencies/gitconfig
    }

    # close fd
    exec 3>&-
}


cleanup () {
    # cleanup as there's no need for this anymore
    if [ -d "$installdir/docker/dependencies" ]; then
        rm -r $installdir/docker/dependencies
    fi
}

# enable gitconfig when it's the first run
SETUP_GITCONFIG=off
SETUP_PREINSTALL=off
if [ ! $FIRSTRUN = "0" ]; then
   SETUP_GITCONFIG=on
   SETUP_PREINSTALL=on
fi

# update devctl script
setup_devctl

### Global configuration ###
cmd=(dialog --separate-output --checklist "Global configuration, select options:" 22 76 16)
options=(autostart "Start docker containers automatically" "$SETUP_RESTART"
         gitconfig "Configure gitconfig" "$SETUP_GITCONFIG"
         varnish "Use Varnish (Magento)" "$SETUP_VARNISH"
         elasticsearch "Use Elasticsearch (Magento)" "$SETUP_ELASTICSEARCH"
         configurator "Skip magento configurator" "$SKIP_CONFIGURATOR"
         xdebug "Enable Xdebug" "$SETUP_XDEBUG"
         xdebug-trigger "Trigger xdebug with request (Default: yes)" "$SETUP_XDEBUG_TRIGGER"
         apache "Apache configurations, for Itix" "$SETUP_APACHE"
         mysql56 "Setup legacy mysql56" "$SETUP_MYSQL56"
         samba "Samba configurations, for Itix" "$SETUP_SAMBA"
         mongo "Mongo containers, for Itix" "$SETUP_MONGO"
)

# reset basic variables after they've been shown in options list
SKIP_CONFIGURATOR=off
SETUP_RESTART=off
SETUP_XDEBUG=off
SETUP_VARNISH=off
SETUP_ELASTICSEARCH=off
SETUP_XDEBUG_TRIGGER=off
SETUP_APACHE=off
SETUP_SAMBA=off
SETUP_MONGO=off
SETUP_MYSQL56=off

settings=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [ -z "$settings" ]; then
    clear
    echo "No settings provided, or cancelled"
    exit 1
fi
for setting in $settings
do :
    case "$setting" in
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
        elasticsearch)
            SETUP_ELASTICSEARCH=on
            ;;
        xdebug)
            SETUP_XDEBUG=on
            ;;
        xdebug-trigger)
            SETUP_XDEBUG_TRIGGER=on
            ;;
        apache)
            SETUP_APACHE=on
            ;;
        samba)
            SETUP_SAMBA=on
            ;;
        mongo)
            SETUP_MONGO=on
            ;;
        mysql56)
            SETUP_MYSQL56=on
            ;;
        *)
            clear
            echo "No settings provided"
            exit 1;
            ;;
    esac        
done

### End Global configuration ###

### Personalization configuration ###

cmd=(dialog --separate-output --checklist "Personalization, select options:" 22 76 16)
options=(starship "Enable starship.rs shell prompt" "$SETUP_STARSHIP")
personalizations=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
# reset personalization settings
SETUP_STARSHIP=off
for personalization in $personalizations
do :
    case "$personalization" in
        starship)
            SETUP_STARSHIP=on
            ;;
        *)
            # continue without personalization
            ;;
    esac        
done

# if ohmyzsh is enabled, disable starship
if [ $SETUP_ZSH == "on" ]; then
    SETUP_STARSHIP=off
fi

### End Personalization configuration ###

# Prepare paths
folders=( "$installdir/docker" "$installdir/data" "$installdir/data/shared/sites" "$installdir/data/shared/media" "$installdir/data/shared/sockets" "$installdir/data/home" "$installdir/data/elasticsearch" "$installdir/data/shared/modules" )
for folder in ${folders[@]}
do :
    if [ ! -d "$folder" ]; then
        mkdir -p $folder
        if [ $? -ne 0 ] ; then
            sudo mkdir -p $folder
            sudo chown -r $USER:$USER $folder
        fi
    fi
done

# replace existing docker compose with new to update settings after a second install
cp ./docker/docker-compose.yml $installdir/docker/docker-compose.yml
cp ./docker/sonarqube.yml $installdir/docker/sonarqube.yml
# cp -r ./docker/* $installdir/docker/

# make sure other services are not forgotten, these are not updated every run
services=( "mailtrap" "nginx" "mysql57" "mysql80" "elasticsearch" )

if [ $SETUP_VARNISH == "on" ] && [ -f docker-compose-snippets/varnish ]; then
    sed -i -e 's/- 80:80/- 8080:80/g' $installdir/docker/docker-compose.yml
    cat docker-compose-snippets/varnish >> $installdir/docker/docker-compose.yml
    services+=( "varnish" )
fi
if [ $SETUP_APACHE == "on" ] && [ -f docker-compose-snippets/apache ]; then
    cat docker-compose-snippets/apache >> $installdir/docker/docker-compose.yml
    services+=( "apache" )
fi
if [ $SETUP_SAMBA == "on" ] && [ -f docker-compose-snippets/samba ]; then
    cat docker-compose-snippets/samba >> $installdir/docker/docker-compose.yml
    services+=( "samba" )
fi
if [ $SETUP_MONGO == "on" ] && [ -f docker-compose-snippets/mongo ]; then
    cat docker-compose-snippets/mongo >> $installdir/docker/docker-compose.yml
    services+=( "mongo" )
fi
if [ $SETUP_ELASTICSEARCH == "on" ] && [ -f docker-compose-snippets/elasticsearch ]; then
    cat docker-compose-snippets/elasticsearch >> $installdir/docker/docker-compose.yml
    services+=( "elasticsearch" )
fi
if [ $SETUP_MYSQL56 == "on" ] && [ -f docker-compose-snippets/mysql56 ]; then
    cat docker-compose-snippets/mysql56 >> $installdir/docker/docker-compose.yml
    services+=( "mysql56" )
fi

for service in "${services[@]}"
do :
    if [ ! -d $installdir/docker/$service ]; then
        mkdir -p $installdir/docker/$service
    fi
    cp -r ./docker/$service/* $installdir/docker/$service
done

### PHP Configurations ###

cmd=(dialog --separate-output --checklist "Select PHP versions:" 22 76 16)
options=(php70 "PHP 7.0" "$PHP70" # any option can be set to default to "on"
         php72 "PHP 7.2" "$PHP72"
         php73 "PHP 7.3" "$PHP73"
         php74 "PHP 7.4" "$PHP74"
         php80 "PHP 8.0" "$PHP80"
         php81 "PHP 8.1" "$PHP81"
         )

# Reset PHP variables
PHP70=off
PHP72=off
PHP73=off
PHP74=off
PHP80=off
PHP81=off

paths=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

if [ -z "$paths" ]; then
    clear
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
    fi

    if [ ! -f "$installdir/data/home/$path/git-autocomplete.sh" ]; then
        cp dep/git-autocomplete.sh $installdir/data/home/$path/
        chmod +x $installdir/data/home/$path/git-autocomplete.sh
    fi
    if [ -f docker-compose-snippets/$path ]; then
        cat docker-compose-snippets/$path >> $installdir/docker/docker-compose.yml
    fi
    cp -r ./docker/$path $installdir/docker/

    if [[ ! -d $installdir/docker/$path/conf.d || ! -f $installdir/docker/$path/conf.d/xdebug.ini ]]; then
        mkdir -p $installdir/docker/$path/conf.d
    fi

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
    
    if [[ ! -d $installdir/docker/$path/php-fpm.d || ! -f $installdir/docker/$path/php-fpm.d/zz-docker.conf ]]; then
        mkdir -p $installdir/docker/$path/php-fpm.d
    fi

    cp ./dep/phprun.sh $installdir/docker/$path/run.sh
    cp ./dep/zz-docker.conf $installdir/docker/$path/php-fpm.d/zz-docker.conf
    sed -i "s/##PHPVERSION##/$phpversion/g" $installdir/docker/$path/run.sh
    sed -i "s/##PHPVERSION##/$phpversion/g" $installdir/docker/$path/php-fpm.d/zz-docker.conf

    if [ $SETUP_GITCONFIG == "on" ]; then
        cp $installdir/docker/dependencies/gitconfig $installdir/data/home/$path/.gitconfig
    fi

done
### End PHP Configurations ###

if [ $SETUP_RESTART == "on" ]; then
    sed -i -e 's/# restart: always/restart: always/g' $installdir/docker/docker-compose.yml
fi

if [ -f "$installdir/docker/docker-compose.yml" ]; then
    #echo "Setting up correct values for docker-compose based on your given installdir"
    sed -i -e 's:installdirectory:'"$installdir"':g' $installdir/docker/docker-compose.yml
fi

if [ ! $FIRSTRUN = "0" ]; then
    # set max_map_count for sonarqube
    # sysctl -w vm.max_map_count=262144
    # make it permanent
    echo "vm.max_map_count=262144" > /etc/sysctl.d/sonarqube.conf
    echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf
    sysctl -p --system
fi

# clear config file and write settings to it
# https://stackoverflow.com/questions/31254887/what-is-the-most-efficient-way-of-writing-a-json-file-with-bash
{
  echo installdir=$installdir >&3
  echo USERNAME=$USERNAME >&3
  echo SKIP_CONFIGURATOR=$SKIP_CONFIGURATOR >&3
  echo SETUP_RESTART=$SETUP_RESTART >&3
  echo SETUP_XDEBUG=$SETUP_XDEBUG >&3
  echo SETUP_VARNISH=$SETUP_VARNISH >&3
  echo SETUP_ELASTICSEARCH=$SETUP_ELASTICSEARCH >&3
  echo SETUP_XDEBUG_TRIGGER=$SETUP_XDEBUG_TRIGGER >&3
  echo SETUP_APACHE=$SETUP_APACHE >&3
  echo SETUP_MYSQL56=$SETUP_MYSQL56 >&3
  echo SETUP_SAMBA=$SETUP_SAMBA >&3
  echo SETUP_MONGO=$SETUP_MONGO >&3
  echo SETUP_STARSHIP=$SETUP_STARSHIP >&3
  echo SETUP_ZSH=$SETUP_ZSH >&3
  echo PHP70=$PHP70 >&3
  echo PHP72=$PHP72 >&3
  echo PHP73=$PHP73 >&3
  echo PHP74=$PHP74 >&3
  echo PHP80=$PHP80 >&3
  echo PHP81=$PHP81 >&3
} 3>$CONFIGFILE

clear
cleanup

# dialog --title "Complete" --backtitle "Run docker compose build and up?" --yesno --defaultno

dialog --stdout --title "Complete" \
  --backtitle "Completed installation" \
  --yesno "Run docker compose build and up?" 7 60
dialog_status=$?

# Do something

if [ "$dialog_status" -eq 0 ]; then
    # The previous dialog was answered Yes
    clear
    cd $installdir/docker && docker compose build && docker compose up -d
    exit $dialogstatus
else
  # The previous dialog was answered No or interrupted with <C-c>
    dialog --title "Complete" --msgbox "Installation prepared \n 
    Config is written to ~/.config/docker-setup.config\n
    - cd to $installdir/docker\n
    - Run docker compose build\n
    - Run docker compose up -d\n
    " 13 60
fi 

clear
exit 0
