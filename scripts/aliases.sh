#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script to          "
echo "* alias useful shell commands for new user   "
echo "* --by Keegan Mullaney                       "
echo "*                                            "
echo "* aliases from nixCraft at:                  "
echo "* http://bit.ly/bash-aliases                 "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
egrep -i "^$USER_NAME" /etc/passwd
if [ $? -eq 0 ]; then
   # alias useful shell commands
   echo "User $USER_NAME exists in /etc/passwd"
   # append aliases to .bashrc if not done already
   read -p "Press enter to add useful aliases..."
   egrep -i "alias wget" $HOME/.bashrc
   if [ $? -eq 0 ]; then
      echo "already added aliases..."
   else
      cat << 'EOF' >> $HOME/.bashrc
## Colorize the ls output
alias ls='ls --color=auto'
 
## Use a long listing format
alias ll='ls -la'
 
## Show hidden files
alias l.='ls -d .* --color=auto'

## get rid of command not found
alias cd..='cd ..'
 
# a quick way to get out of current directory
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias .....='cd ../../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'

## Colorize the grep command output for ease of use (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Start calculator with math support
alias bc='bc -l'

# Generate sha1 digest
#alias sha1='openssl sha1'

# mkdir command is used to create a directory:
alias mkdir='mkdir -pv'

# Colorize diff output
#alias diff='colordiff'

# Make mount command output pretty and human readable format
alias mount='mount | column -t'

# handy short cuts
alias h='history'
alias j='jobs -l'

# Create a new set of commands
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Set vim as default
#alias vi=vim
alias svi='sudo vi'
#alias vis='vim "+set si"'
#alias edit='vim'

# Stop after sending count ECHO_REQUEST packets
alias ping='ping -c 5'
# Do not wait interval 1 second, go fast
alias fastping='ping -c 100 -s.2'

# show open ports
alias ports='netstat -tulanp'

# replace mac with your actual server mac address
#alias wakeupnas01='/usr/bin/wakeonlan 00:11:32:11:15:FC'
#alias wakeupnas02='/usr/bin/wakeonlan 00:11:32:11:15:FD'
#alias wakeupnas03='/usr/bin/wakeonlan 00:11:32:11:15:FE'

# shortcut  for iptables and pass it via sudo
alias ipt='sudo /sbin/iptables'
 
# display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
alias firewall=iptlist

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

# distro specifc RHEL/CentOS
alias update='yum update'
alias updatey='yum -y update'

# become root
alias root='sudo -i'
alias su='sudo -i'

# reboot / halt / poweroff
alias reboot='sudo /sbin/reboot'
alias poweroff='sudo /sbin/poweroff'
alias halt='sudo /sbin/halt'
alias shutdown='sudo /sbin/shutdown'

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

# All of our servers eth1 is connected to the Internets via vlan / router etc
alias dnstop='dnstop -l 5  eth1'
alias vnstat='vnstat -i eth1'
alias iftop='iftop -i eth1'
alias tcpdump='tcpdump -i eth1'
alias ethtool='ethtool eth1'
 
# work on wlan0 by default
# Only useful for laptops as all servers are without wireless interface
alias iwconfig='iwconfig wlan0'

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

# older system use /proc/cpuinfo
#alias cpuinfo='less /proc/cpuinfo'

## get GPU ram on desktop / laptop
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

# resume downloads
alias wget='wget -c'
EOF
      echo "$HOME/.bashrc was updated"
      read -p "Press enter to print .bashrc"
      cat $HOME/.bashrc
   fi
else
   echo "User $USER_NAME does not exists in /etc/passwd, please create user $USER_NAME before adding aliases"
fi
echo
echo "done with aliases.sh"

