#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* alias useful shell commands for new user   "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* aliases from nixCraft:                     "
echo "* http://bit.ly/bash-aliases                 "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
if cat /etc/passwd | grep -q "^$USER_NAME"; then
   # alias useful shell commands
   echo "User $USER_NAME exists in /etc/passwd"
   # append aliases to .bashrc if not done already
   read -p "Press enter to add useful aliases..."
   if cat /home/$USER_NAME/.bashrc | grep -q "alias wget"; then
      echo "already added aliases..."
   else
      cat << 'EOF' >> /home/$USER_NAME/.bashrc
#

# Colorize the ls output
alias ls='ls --color=auto'
 
# Use a long listing format
alias ll='ls -la --color=auto'
 
# Show hidden files
alias l.='ls -d .* --color=auto'

# Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Start calculator with math support
alias bc='bc -l'

# mkdir command is used to create a directory:
alias mkdir='mkdir -pv'

# Make mount command output pretty and human readable format
alias mount='mount | column -t'

# Create a new set of commands
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Stop after sending count ECHO_REQUEST packets
alias ping='ping -c 5'
# Do not wait interval 1 second, go fast
alias fastping='ping -c 100 -s.2'

# show open ports
alias ports='netstat -tulanp'

# shortcut for firewall-cmd in CentOS 7
alias fc='firewall-cmd'

# shortcut for systemctl in CentOS 7
alias sc='systemctl'

# get web server headers
alias header='curl -I'
 
# find out if remote server supports gzip / mod_deflate or not
alias headerc='curl -I --compress'

# do not delete / or prompt if deleting more than 3 files at a time
alias rm='rm -I --preserve-root'
 
# confirmation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
 
# Parenting changing perms on /
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# become root
alias su='/bin/su'

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

# pass options to free
alias meminfo='free -m -l -t'

# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

# get top process eating cpu
alias pscpu='ps auxf | sort -nr -k 3'

# test nginx
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

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

echo "done with aliases.sh"

