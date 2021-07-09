#!/bin/bash
cmd=(dialog --separate-output --checklist "Select PHP versions:" 22 76 16)
options=(php56 "PHP 5.6" off    # any option can be set to default to "on"
         php70 "PHP 7.0" off
         php71 "PHP 7.1" off
         php72 "PHP 7.2" off
         php73 "PHP 7.3" on
         php74 "PHP 7.4" on
         php80 "PHP 8.0" off)
paths=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
#paths=( "php71" "php72" "php73" "php74" "php80" )
#clear
for path in $paths
#for path in "${paths[@]}"
do :
    echo $path
done
