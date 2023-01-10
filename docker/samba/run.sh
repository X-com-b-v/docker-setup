#!/bin/bash

/etc/init.d/smbd start
/etc/init.d/smbd status

if [ $? -eq 0 ];then
  tail -f /var/log/samba/log.smbd
else
  exit $?
fi
