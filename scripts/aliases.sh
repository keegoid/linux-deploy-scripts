#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* alias useful shell commands for new user   "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
if user_exists $USER_NAME; then
   # append aliases to .bashrc if not done already
   read -p "Press enter to add useful aliases for $USER_NAME..."
   if grep -q "alias wget" /home/$USER_NAME/.bashrc; then
      echo "already added aliases for $USER_NAME..."
   else
      # alias useful shell commands
      cat << 'EOF' >> /home/$USER_NAME/.bashrc
# add color
alias ls='ls --color=auto'
 
# add color and show file properties 
alias ll='ls -la --color=auto'
 
# add color and show hidden files
alias l.='ls -d .* --color=auto'

# add color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# make directories and parents
alias mkdir='mkdir -pv'

# list open ports
alias ports='netstat -tulanp'

# shortcut for firewall-cmd in CentOS 7
alias fc='firewall-cmd'

# shortcut for systemctl in CentOS 7
alias sc='systemctl'

# display headers
alias header='curl -I'
 
# display headers that support compression 
alias headerc='curl -I --compress'

# delete protection
alias rm='rm -I --preserve-root'
 
# confirm operation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# become root
alias su='/bin/su'

# reboot and shutdown
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/shutdown'

# list memory info
alias meminfo='free -m -l -t'

# nginx test
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

# CentOS version
alias osversion='cat /etc/*release*'

# resume downloads
alias wget='wget -c'
EOF
      echo "/home/$USER_NAME/.bashrc was updated"
      read -p "Press enter to also add aliases for $HOME"
      cat << 'EOF' >> $HOME/.bashrc
# add color
alias ls='ls --color=auto'
 
# add color and show file properties 
alias ll='ls -la --color=auto'
 
# add color and show hidden files
alias l.='ls -d .* --color=auto'

# add color
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# make directories and parents
alias mkdir='mkdir -pv'

# list open ports
alias ports='netstat -tulanp'

# shortcut for firewall-cmd in CentOS 7
alias fc='firewall-cmd'

# shortcut for systemctl in CentOS 7
alias sc='systemctl'

# display headers
alias header='curl -I'
 
# display headers that support compression 
alias headerc='curl -I --compress'

# delete protection
alias rm='rm -I --preserve-root'
 
# confirm operation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# become root
alias su='/bin/su'

# reboot and shutdown
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/shutdown'

# list memory info
alias meminfo='free -m -l -t'

# nginx test
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

# CentOS version
alias osversion='cat /etc/*release*'

# resume downloads
alias wget='wget -c'
EOF
      echo "$HOME/.bashrc was updated"
      read -p "Press enter to print .bashrc"
      cat $HOME/.bashrc
   fi
else
   echo "please create user $USER_NAME before adding aliases"
fi
