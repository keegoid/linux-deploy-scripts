#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* install Middleman and dependencies         "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# install Ruby and RubyGems
read -p "Press enter to install ruby and rubygems..."
if ruby -v | grep -q "ruby $RUBY_VERSION"; then
   echo "ruby is already installed"
else
   curl -L https://get.rvm.io | bash -s stable --ruby=$RUBY_VERSION
fi

# start using rvm
echo
read -p "Press enter to start using rvm..."
if cat /home/$USER_NAME/.bashrc | grep -q "/usr/local/rvm/scripts/rvm"; then
   echo "already added rvm to .bashrc"
else
   echo "source /usr/local/rvm/scripts/rvm" >> /home/$USER_NAME/.bashrc
   source /usr/local/rvm/scripts/rvm && echo "rvm sourced and added to .bashrc"
fi

# update gems
echo
read -p "Press enter to update gems..."
gem update

echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install Node.js and NPM
#echo
#read -p "Press enter to install nodejs and npm..."
#yum --enablerepo=epel -y install nodejs npm

# install Middleman
if $(gem list middleman -i); then
   echo "middleman gem already installed"
else
   echo
   read -p "Press enter to install middleman..."
   gem install middleman
fi

# install Redcarpet (for Markdown file processing)
if $(gem list redcarpet -i); then
   echo "redcarpet gem already installed"
else
   echo
   read -p "Press enter to install redcarpet..."
   gem install redcarpet
fi

# install Rouge (for code syntax highlighting)
if $(gem list rouge -i); then
   echo "rouge gem already installed"
else
   echo
   read -p "Press enter to install rouge..."
   gem install rouge
fi

# Middleman web root
#mkdir -p /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -R $USER_NAME:$USER_NAME $_
#echo "made directory: $_ and set permissions to $USER_NAME"

# Middleman repository
MM_DIRECTORY="/home/$USER_NAME/repos/$MIDDLEMAN_DOMAIN"
if [ -d $MM_DIRECTORY ]; then
   echo "$MM_DIRECTORY directory already exists"
else
   echo
   read -p "Press enter to create repos directory for $USER_NAME..."
   mkdir -p $MM_DIRECTORY
   echo "made directory: $_"
fi

# change to repos directory
cd $MM_DIRECTORY
echo "changing directory to $_"

# generate a blog template for Middleman
if [ -d "$MM_DIRECTORY/$MIDDLEMAN_PROJECT" ]; then
   echo "$MIDDLEMAN_PROJECT directory already exists, skipping clone operation..."
else
   echo
   echo "Before proceeding, make sure to fork $UPSTREAM_REPO and change the project name to $MIDDLEMAN_PROJECT on GitHub"
   read -p "Press enter to clone $MIDDLEMAN_PROJECT from GitHub..."
   echo
   echo "Do you wish to clone using HTTPS or SSH (recommended)?"
   select hs in "HTTPS" "SSH"; do
      case $hs in
         "HTTPS") git clone https://github.com/$GITHUB_USER/$MIDDLEMAN_PROJECT.git;;
           "SSH") git clone git@github.com:$GITHUB_USER/$MIDDLEMAN_PROJECT.git;;
               *) echo "case not found..."
      esac
      break
   done
   # TODO: give user option to start from a fresh Middleman app
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=html5
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=blog
fi

# change to newly cloned directory
cd $MIDDLEMAN_PROJECT
echo "changing directory to $_"

# assign the original repository to a remote called "upstream"
if git config --list | grep -q $UPSTREAM_REPO; then
   echo "upstream repo already configured: https://github.com/$UPSTREAM_REPO"
else
   echo
   read -p "Press enter to assign upstream repository..."
   git remote add upstream https://github.com/$UPSTREAM_REPO && echo "remote upstream added for https://github.com/$UPSTREAM_REPO"
fi

# pull in changes not present local repository, without modifying local files
echo
read -p "Press enter to fetch changes from upstream repository..."
git fetch upstream
echo "upstream fetch done"

# merge any changes fetched into local working files
echo
read -p "Press enter to merge changes..."
git merge upstream/master

# specify middleman-bitballoon extension in the Gemfile
if cat Gemfile | grep -q "rouge"; then
   echo "Rouge syntax highligting already configured"
else
   echo
   read -p "Press enter to configure the Gemfile..."
   echo '# Ruby based syntax highlighting' >> Gemfile
   echo 'gem "rouge"' >> Gemfile
   echo "rouge added to Gemfile"
fi 
if cat Gemfile | grep -q "middleman-bitballoon"; then
   echo "BitBalloon extension already configured"
else
   echo '' >> Gemfile
   echo '# Middleman extension for deploying to BitBalloon' >> Gemfile
   echo 'gem "middleman-bitballoon"' >> Gemfile
   echo "middleman-bitballoon added to Gemfile"
fi

# configure BitBalloon extension in config.rb
if cat config.rb | grep -q "bitballoon.build_before"; then
   echo "BitBalloon extension already configured"
else
   echo
   read -p "Press enter to configure config.rb..."
   if cat /home/$USER_NAME/.bash_profile | grep -q "BB_TOKEN"; then
      echo "BB_TOKEN already entered in .bash_profile for user: $USER_NAME"
   else
      read -e -p "Paste your BitBalloon app token here: " GET_TOKEN
      echo -e "\nexport BB_TOKEN=${GET_TOKEN}" >> /home/$USER_NAME/.bash_profile
   fi
   cat << EOF >> config.rb
# middleman-bitballoon extension
activate :bitballoon do |bitballoon|
  bitballoon.token = ENV["BB_TOKEN"]
  bitballoon.site  = "${MIDDLEMAN_DOMAIN%.*}.bitballoon.com"

  # Optional: always run a build before deploying
  bitballoon.build_before = true
end
EOF
   echo "BitBalloon extension configured"
fi

# set permissions
echo
read -p "Press enter to change to set permissions..."
chown -R $USER_NAME:$USER_NAME $MM_DIRECTORY
echo "set permissions on $MM_DIRECTORY to $USER_NAME"

# update gems
echo
read -p "Press enter to update gems..."
gem update

echo "done with middleman.sh"

