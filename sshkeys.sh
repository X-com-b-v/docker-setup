#!/usr/bin/env bash

echo "Please enter the directory you want to install base to (without trailing slash)"
read installdir
paths=( "php56" "php70" "php71" "php72" "php73" "php74" )
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
      if [ -d "/home/$SUDO_USER/.ssh/X-com" ]; then
        cp -r /home/$SUDO_USER/.ssh/X-com $installdir/data/home/$path/.ssh/
      fi
      cp /home/$SUDO_USER/.ssh/id_rsa $installdir/data/home/$path/.ssh/
      cp /home/$SUDO_USER/.ssh/id_rsa.pub $installdir/data/home/$path/.ssh/
      # chmod -r 400 $installdir/data/home/$path/.ssh/*
    done
  fi
fi

