#!/usr/bin/env bash

CONFIGFILE="$HOME"/.config/docker-setup.config
if [ -f "$CONFIGFILE" ]; then
    # shellcheck disable=SC1090
    . "$CONFIGFILE"
else
    FIRSTRUN=1
fi

dialog --title "Welcome" --msgbox "Welcome to the docker-setup \n
This installer will provide you with options \n
to select different services. Please read carefully. \n
Read the docs at https://xcom-nl.atlassian.net/wiki/spaces/DEVENV/ \n
Or in the README.md provided in the root dir of this project. \n
" 13 60

# load current version
# shellcheck disable=SC1091
. "./version.sh"

while [[ -z "$USERNAME" ]]; do
    exec 3>&1
    USERNAME=$(dialog --title "username" --inputbox "Enter your username" 6 60 "$USERNAME" 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
done

originstalldir=
while [[ -z $originstalldir ]]; do
    exec 3>&1
    origdir="$HOME/x-com"
    if [ -n "$installdir" ]; then
        origdir=$installdir
    fi
    originstalldir=$(dialog --inputbox "Full path to install directory \n" 8 60 "$origdir" 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
        clear
        exit $exitcode
    fi
done

#shellcheck disable=SC2001
installdir=$(echo "$originstalldir" | sed 's:/*$::')

if [ -z "$installdir" ]; then
    installdir="/"
fi

# create installdir if it does not exist, elevate permissions if necessary
if [ ! -d "$installdir" ] ; then
    if ! mkdir -p "$installdir"; then
        sudo mkdir -p "$installdir"
        sudo chown -r "$USER":"$USER" "$installdir"
    fi
elif [ -d "$installdir" ]; then
    FIRSTRUN=0
fi

# always enable gitconfig and mysql when it's the first run
if [ "$FIRSTRUN" == "1" ]; then
   SETUP_GITCONFIG=on
   SETUP_MYSQL57=on
   SETUP_MYSQL80=on
fi

# This is volume mapped, so directory should exist
if [ ! -d "$HOME/.ssh" ] ; then
    mkdir -p "$HOME/.ssh"
fi

# set default project slug
if [ -z "$PROJECTSLUG" ]; then
    PROJECTSLUG=".o.xotap.nl"
fi

setup_devctl () {
    if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
    fi
    cp dep/devctl.sh "$HOME/.local/bin/devctl"
    cp dep/enter.sh "$HOME/.local/bin/enter"
    cp dep/nginx-sites.sh "$HOME/.local/bin/nginx-sites"
    sed -i -e 's:installdirectory:'"$installdir"':g' "$HOME/.local/bin/devctl"
    chmod +x "$HOME/.local/bin/devctl"
    chmod +x "$HOME/.local/bin/enter"
    chmod +x "$HOME/.local/bin/nginx-sites.sh"
}

setup_gitconfig () {
    if [ ! -d "$installdir/docker/dependencies" ]; then
        mkdir -p "$installdir/docker/dependencies"
    fi
    cp ./dep/gitconfig "$installdir/docker/dependencies/"

    if [ -z "$GIT_USER" ]; then
        GIT_USER=$(echo "${USER}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    fi
    # open fd
    exec 3>&1
    # Store data to $VALUES variable
    VALUES=$(dialog --ok-label "Submit" \
        --backtitle "Gitconfig" \
        --title "Gitconfig" \
        --form "Add git user information" \
    15 50 0 \
        "Name:" 1 1	"$GIT_USER" 	1 10 39 0 \
        "E-mail:"   2 1	"$GIT_EMAIL"  	2 10 40 0 \
    2>&1 1>&3)
    # close fd
    exec 3>&-
    # convert values to array
    i=0
    while read -r line; do
        ((i++))
        declare GIT_DATA$i="${line}"
    done <<< "${VALUES}"
    GIT_USER="${GIT_DATA1}"
    GIT_EMAIL="${GIT_DATA2}"
    sed -i -e 's:username:'"$GIT_USER"':g' "$installdir/docker/dependencies/gitconfig"
    sed -i -e 's:user@email.com:'"$GIT_EMAIL"':g' "$installdir/docker/dependencies/gitconfig"
}

setup_projectslug () {
    exec 3>&1
    PROJECTSLUG=$(dialog --inputbox "Change project slug \n" 8 60 "$PROJECTSLUG" 2>&1 1>&3)
    exitcode=$?;
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
        clear
        exit $exitcode
    fi
}

cleanup () {
    # cleanup as there's no need for this anymore
    if [ -d "$installdir/docker/dependencies" ]; then
        rm -r "$installdir"/docker/dependencies
    fi
}

# update devctl script
setup_devctl

### Global configuration ###
cmd=(dialog --separate-output --checklist "Global configuration, select options:" 22 76 16)
options=(autostart "Start docker containers automatically" "$SETUP_RESTART"
         gitconfig "Configure gitconfig" "$SETUP_GITCONFIG"
         mysql57 "Setup mysql 5.7" "$SETUP_MYSQL57"
         mysql80 "Setup mysql 8.0" "$SETUP_MYSQL80"
         projectslug "Change project slug [$PROJECTSLUG]" "$SETUP_PROJECTSLUG"
         varnish "Use Varnish (Magento)" "$SETUP_VARNISH"
         elasticsearch "Use Elasticsearch (Magento)" "$SETUP_ELASTICSEARCH"
         configurator "Skip configurator (Magento)" "$SKIP_CONFIGURATOR"
         xdebug "Enable Xdebug" "$SETUP_XDEBUG"
         xdebug-trigger "Trigger xdebug with request (Default: yes)" "$SETUP_XDEBUG_TRIGGER"
         apache "Apache configurations, for Itix" "$SETUP_APACHE"
         mongo "Mongo" "$SETUP_MONGO"
         mysql56 "Setup mysql 5.6 (Deprecated)" "$SETUP_MYSQL56"
)

# reset basic variables after they've been shown in options list
SKIP_CONFIGURATOR=off
SETUP_RESTART=off
SETUP_XDEBUG=off
SETUP_VARNISH=off
SETUP_ELASTICSEARCH=off
SETUP_XDEBUG_TRIGGER=off
SETUP_APACHE=off
SETUP_MONGO=off
SETUP_MYSQL56=off
SETUP_MYSQL57=off
SETUP_MYSQL80=off
SETUP_GITCONFIG=off
SETUP_PROJECTSLUG=off

settings=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [ -z "$settings" ]; then
    clear
    echo "No settings provided, or cancelled"
    cleanup
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
        projectslug)
            setup_projectslug
            SETUP_PROJECTSLUG=on
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
        mongo)
            SETUP_MONGO=on
            ;;
        mysql56)
            SETUP_MYSQL56=on
            ;;
        mysql57)
            SETUP_MYSQL57=on
            ;;
        mysql80)
            SETUP_MYSQL80=on
            ;;
        *)
            clear
            echo "No settings provided"
            cleanup
            exit 1;
            ;;
    esac
done
### End Global configuration ###

### Personalization configuration ###
cmd=(dialog --separate-output --checklist "Personalization, select options:" 22 55 16)
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
### End Personalization configuration ###

dialog --stdout --title "Prepare" \
  --backtitle "Cleanup" \
  --defaultno \
  --yesno "Clean up old home directories?" 7 60
dialog_status=$?
if [ "$dialog_status" -eq 0 ]; then
    clear
    while IFS= read -r d
    do
        rm -r "$d"
    done <   <(find -L "$installdir"/data/home -mindepth 1 -maxdepth 1 -type d)
fi

# Prepare paths
folders=( "$installdir/docker" "$installdir/data" "$installdir/data/shared/sites" "$installdir/data/shared/media" "$installdir/data/shared/sockets" "$installdir/data/home" "$installdir/data/elasticsearch" "$installdir/data/shared/modules" "$installdir/docker/nginx/sites-enabled" )
for folder in "${folders[@]}"
do :
    if [ ! -d "$folder" ]; then
        if ! mkdir -p "$folder" ; then
            sudo mkdir -p "$folder"
            sudo chown -r "$USER":"$USER" "$folder"
        fi
    fi
done

# replace existing docker compose with new to update settings after a second install
cp ./docker/docker-compose.yml "$installdir"/docker/docker-compose.yml
cp ./docker/sonarqube.yml "$installdir"/docker/sonarqube.yml

# make sure other services are not forgotten, these are not updated every run
services=( "mailtrap" "nginx" "mysql57" "mysql80" "elasticsearch" )

if [ $SETUP_VARNISH == "on" ] && [ -f docker-compose-snippets/varnish ]; then
    sed -i -e 's/- 80:80/- 8080:80/g' "$installdir"/docker/docker-compose.yml
    cat docker-compose-snippets/varnish >> "$installdir"/docker/docker-compose.yml
    services+=( "varnish" )
fi
if [ $SETUP_APACHE == "on" ] && [ -f docker-compose-snippets/apache ]; then
    cat docker-compose-snippets/apache >> "$installdir"/docker/docker-compose.yml
    services+=( "apache" )
fi
if [ $SETUP_MONGO == "on" ] && [ -f docker-compose-snippets/mongo ]; then
    cat docker-compose-snippets/mongo >> "$installdir"/docker/docker-compose.yml
    services+=( "mongo" )
fi
if [ $SETUP_ELASTICSEARCH == "on" ] && [ -f docker-compose-snippets/elasticsearch ]; then
    cat docker-compose-snippets/elasticsearch >> "$installdir"/docker/docker-compose.yml
    services+=( "elasticsearch" )
fi
if [ $SETUP_MYSQL56 == "on" ] && [ -f docker-compose-snippets/mysql56 ]; then
    cat docker-compose-snippets/mysql56 >> "$installdir"/docker/docker-compose.yml
    services+=( "mysql56" )
fi
if [ $SETUP_MYSQL57 == "on" ] && [ -f docker-compose-snippets/mysql57 ]; then
    cat docker-compose-snippets/mysql57 >> "$installdir"/docker/docker-compose.yml
    services+=( "mysql80" )
fi
if [ $SETUP_MYSQL80 == "on" ] && [ -f docker-compose-snippets/mysql80 ]; then
    cat docker-compose-snippets/mysql80 >> "$installdir"/docker/docker-compose.yml
    services+=( "mysql80" )
fi

for service in "${services[@]}"
do :
    if [ ! -d "$installdir"/docker/"$service" ]; then
        mkdir -p "$installdir"/docker/"$service"
    fi
    cp -r ./docker/"$service"/* "$installdir"/docker/"$service"
done

### PHP Configurations ###

cmd=(dialog --separate-output --checklist "Select PHP versions:" 16 35 16)
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
    cleanup
    exit 1
fi
for path in $paths
do :
    # use printf to assign php value
    # https://stackoverflow.com/a/55331060
    # macos compatibility.
    UPATH=$(echo "${path}" | awk '{print toupper($0)}')
    printf -v "${UPATH}" '%s' 'on'

    if [ ! -d "$installdir/data/home/$path" ]; then
        mkdir -p "$installdir/data/home/$path"
    fi

    if [ ! -f "$installdir/data/home/$path/git-autocomplete.sh" ]; then
        cp dep/git-autocomplete.sh "$installdir"/data/home/"$path"/
        chmod +x "$installdir"/data/home/"$path"/git-autocomplete.sh
    fi
    if [ -f docker-compose-snippets/"$path" ]; then
        cat docker-compose-snippets/"$path" >> "$installdir"/docker/docker-compose.yml
    fi
    cp -r ./docker/"$path" "$installdir"/docker/

    if [[ ! -d $installdir/docker/$path/conf.d || ! -f $installdir/docker/$path/conf.d/xdebug.ini ]]; then
        mkdir -p "$installdir"/docker/"$path"/conf.d
    fi

    # copy configs
    cp ./dep/xdebug.ini "$installdir"/docker/"$path"/conf.d/
    cp ./dep/opcache.ini "$installdir"/docker/"$path"/conf.d/

    if [ $SETUP_XDEBUG == "off" ]; then
        sed -i -e 's/xdebug.mode=debug,develop/;xdebug.mode=debug,develop/g' "$installdir"/docker/"$path"/conf.d/xdebug.ini
        sed -i -e 's/;xdebug.mode=off/xdebug.mode=off/g' "$installdir"/docker/"$path"/conf.d/xdebug.ini
    fi

    if [ $SETUP_XDEBUG_TRIGGER == "on" ]; then
        sed -i -e 's/xdebug.start_with_request=yes/;xdebug.start_with_request=yes/g' "$installdir"/docker/"$path"/conf.d/xdebug.ini
        sed -i -e 's/;xdebug.start_with_request=trigger/xdebug.start_with_request=trigger/g' "$installdir"/docker/"$path"/conf.d/xdebug.ini
    fi

    position=4
    phpversion="$path"
    phpversion="${phpversion:0:position}.${phpversion:position}"

    if [[ ! -d $installdir/docker/$path/php-fpm.d || ! -f $installdir/docker/$path/php-fpm.d/zz-docker.conf ]]; then
        mkdir -p "$installdir"/docker/"$path"/php-fpm.d
    fi

    cp ./dep/phprun.sh "$installdir"/docker/"$path"/run.sh
    cp ./dep/zz-docker.conf "$installdir"/docker/"$path"/php-fpm.d/zz-docker.conf
    sed -i "s/##PHPVERSION##/$phpversion/g" "$installdir"/docker/"$path"/run.sh
    sed -i "s/##PHPVERSION##/$phpversion/g" "$installdir"/docker/"$path"/php-fpm.d/zz-docker.conf

    if [ $SETUP_GITCONFIG == "on" ]; then
        cp "$installdir"/docker/dependencies/gitconfig "$installdir"/data/home/"$path"/.gitconfig
    fi
done
### End PHP Configurations ###

if [ $SETUP_RESTART == "on" ]; then
    sed -i -e 's/# restart: always/restart: always/g' "$installdir"/docker/docker-compose.yml
fi

if [ -f "$installdir/docker/docker-compose.yml" ]; then
    #echo "Setting up correct values for docker-compose based on your given installdir"
    sed -i -e 's:installdirectory:'"$installdir"':g' "$installdir"/docker/docker-compose.yml
fi

if [ ! "$FIRSTRUN" = "0" ]; then
    # set max_map_count for sonarqube
    # sysctl -w vm.max_map_count=262144
    # make it permanent
    echo "vm.max_map_count=262144" > /etc/sysctl.d/sonarqube.conf
    echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf
    sysctl -p --system
fi

if [ ! -d "$HOME"/.config ]; then
    mkdir -p "$HOME"/.config
fi

# clear config file and write settings to it
# https://stackoverflow.com/questions/31254887/what-is-the-most-efficient-way-of-writing-a-json-file-with-bash
{
  echo installdir="$installdir" >&3
  echo VERSION="$VERSION" >&3
  echo USERNAME="$USERNAME" >&3
  echo SKIP_CONFIGURATOR=$SKIP_CONFIGURATOR >&3
  echo SETUP_RESTART=$SETUP_RESTART >&3
  echo SETUP_XDEBUG=$SETUP_XDEBUG >&3
  echo SETUP_VARNISH=$SETUP_VARNISH >&3
  echo SETUP_ELASTICSEARCH=$SETUP_ELASTICSEARCH >&3
  echo SETUP_XDEBUG_TRIGGER=$SETUP_XDEBUG_TRIGGER >&3
  echo SETUP_APACHE=$SETUP_APACHE >&3
  echo SETUP_MYSQL56=$SETUP_MYSQL56 >&3
  echo SETUP_MYSQL57=$SETUP_MYSQL57 >&3
  echo SETUP_MYSQL80=$SETUP_MYSQL80 >&3
  echo SETUP_MONGO=$SETUP_MONGO >&3
  echo SETUP_STARSHIP=$SETUP_STARSHIP >&3
  echo SETUP_GITCONFIG=$SETUP_GITCONFIG >&3
  echo GIT_USER=\""${GIT_USER}"\" >&3
  echo GIT_EMAIL="$GIT_EMAIL" >&3
  echo PROJECTSLUG="$PROJECTSLUG" >&3
  echo PHP70=$PHP70 >&3
  echo PHP72=$PHP72 >&3
  echo PHP73=$PHP73 >&3
  echo PHP74=$PHP74 >&3
  echo PHP80=$PHP80 >&3
  echo PHP81=$PHP81 >&3
} 3>"$CONFIGFILE"

clear
cleanup

dialog --stdout --title "Complete" \
  --backtitle "Completed installation" \
  --yesno "Run docker compose build and up?" 7 60
dialog_status=$?
if [ "$dialog_status" -eq 0 ]; then
    # The previous dialog was answered Yes
    clear
    cd "$installdir/docker" && docker compose pull && docker compose up --remove-orphans --build -d
    exit "$dialog_status"
else
  # The previous dialog was answered No or interrupted with <C-c>
    dialog --title "Complete" --msgbox "Installation prepared \n
    Config is written to $HOME/.config/docker-setup.config\n
    - cd to $installdir/docker\n
    - Run docker compose up --build -d\n
    " 13 60
fi

clear
echo "Read the docs at https://xcom-nl.atlassian.net/wiki/spaces/DEVENV"
exit 0
