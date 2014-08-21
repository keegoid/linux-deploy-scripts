#!/bin/bash
# configure sudoers file
# chmod u+x sudoers.sh
# run with sudo ./sudoers.sh
# username (change below in two places): kmullaney
if [ -z "$1" ]; then
   echo "Starting up visudo with this script as first parameter"
   export EDITOR=$0 && /usr/sbin/visudo
else
   egrep -i "kmullaney" $1
   if [ $? -eq 0 ]; then
      echo "sudoers already updated"
   else
      echo "Changing sudoers"
      sed -i.bak -e "/Allow root to run any commands anywhere/a kmullaney  ALL=(ALL)       ALL" -e "s/Defaults    always_set_home/Defaults    timestamp_timeout=30, always_set_home, log_year, tty_tickets, logfile=\/var\/log\/sudo_users_log/" $1
   fi
fi
