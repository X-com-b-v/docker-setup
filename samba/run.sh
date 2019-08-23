#!/bin/bash

/etc/init.d/samba start
/etc/init.d/samba status

if [ $? -eq 0 ];then
  tail -f /var/log/samba/log.smbd
else
  exit $?
fi
