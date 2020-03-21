#!/usr/bin/env bash

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

if [ ! -f /usr/local/bin/devctl ]; then
  cp dep/devctl /usr/local/bin/devctl
  sed -i -e 's:installdirectory:'"$installdir"':g' /usr/local/bin/devctl
  chmod +x /usr/local/bin/devctl
fi

