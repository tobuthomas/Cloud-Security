#!/bin/bash
# if the user running this script is not the "sysadmin" then run the echo command
if [ $USER != 'sysadmin' ]
then
  echo "You are not sysadmin!"
  exit
fi

