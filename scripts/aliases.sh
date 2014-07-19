#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script to          "
echo "* alias useful shell commands for new user   "
echo "* --by Keegan Mullaney                       "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
egrep -i "^${USER_NAME}" /etc/passwd
if [ $? -eq 0 ]; then
   # alias useful shell commands
   echo "User $USER_NAME exists in /etc/passwd"
   # append aliases to .bashrc if not done already
   read -p "Press enter to add useful aliases..."
   egrep -i "alias wget" /home/$USER_NAME/.bashrc
   if [ $? -eq 0 ]; then
      echo "already added aliases..."
   else
      cat << 'EOF' >> /home/$USER_NAME/.bashrc
# do not delete / or prompt if deleting more than 3 files at a time
alias rm='rm -I --preserve-root'

# confirmation
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'

# colorize the ls output
alias ls='ls --color=auto'

# use a long listing format
alias ll='ls -la'

# show hidden files
alias l.='ls -d .* --color=auto'

# colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Make mount command output pretty and human readable format
alias mount='mount |column -t'

# create parent directories on demand
alias mkdir='mkdir -pv'

# show path
alias path='echo -e ${PATH//:/\\n}'

# show open ports
alias ports='netstat -tulanp'

# parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

# become root
alias root='sudo -i'
alias su='sudo -i'

# control web servers
alias nginxreload='sudo /usr/local/nginx/sbin/nginx -s reload'
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

# pass options to free
alias meminfo='free -m -l -t'

# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# get top process eating cpu
alias pscpu='ps auxf | sort -nr -k 3'
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

# pass options to free
alias meminfo='free -m -l -t'

# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# get top process eating cpu
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

# get server cpu info
alias cpuinfo='lscpu'

# resume downloads
alias wget='wget -c'
EOF
      echo "/home/$USER_NAME/.bashrc was updated"
      read -p "Press enter to print .bashrc"
      cat /home/$USER_NAME/.bashrc
   fi
else
   echo "User $USER_NAME does not exists in /etc/passwd, please create user $USER_NAME before adding aliases"
fi
echo
echo "done with aliases.sh"

