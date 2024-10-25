#!/usr/bin/env bash

setup_devctl() {
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

setup_gitconfig() {
    if [ ! -d "$installdir/docker/dependencies" ]; then
        mkdir -p "$installdir/docker/dependencies"
    fi
    cp ./dep/gitconfig "$installdir/docker/dependencies/"

    if [ -z "$GIT_USER" ]; then
        GIT_USER=$(echo "${USER}" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')
    fi
    exec 3>&1
    VALUES=$(dialog --ok-label "Submit" \
        --backtitle "Gitconfig" \
        --title "Gitconfig" \
        --form "Add git user information" \
    15 50 0 \
        "Name:" 1 1 "$GIT_USER" 1 10 39 0 \
        "E-mail:" 2 1 "$GIT_EMAIL" 2 10 40 0 \
    2>&1 1>&3)
    exec 3>&-
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

setup_projectslug() {
    exec 3>&1
    PROJECTSLUG=$(dialog --inputbox "Change project slug \n" 8 60 "$PROJECTSLUG" 2>&1 1>&3)
    exitcode=$?
    exec 3>&-;
    if [ ! $exitcode = "0" ]; then
        clear
        exit $exitcode
    fi
}

prepare_paths() {
    folders=( "$installdir/docker" "$installdir/data" "$installdir/data/shared/sites" "$installdir/data/shared/media" "$installdir/data/home" "$installdir/data/shared/modules" "$installdir/docker/nginx/sites-enabled" "$installdir/docker/apache/sites-enabled" )
    for folder in "${folders[@]}"
    do :
        if [ ! -d "$folder" ]; then
            if ! mkdir -p "$folder" ; then
                sudo mkdir -p "$folder"
                sudo chown -r "$USER":"$USER" "$folder"
            fi
        fi
    done
}

replace_docker() {
    cp ./docker/docker-compose.yml "$installdir"/docker/docker-compose.yml
}

cleanup() {
    if [ -d "$installdir/docker/dependencies" ]; then
        rm -rf "$installdir/docker/dependencies" || {
            echo "Failed to remove dependencies directory"
            exit 1
        }
    else
        echo "No dependencies directory found"
    fi
}