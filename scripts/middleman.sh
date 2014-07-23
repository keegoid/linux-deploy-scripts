#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script to          "
echo "* install Middleman and dependencies and     "
echo "* deploy to BitBalloon                       "
echo "* --by Keegan Mullaney                       "
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

# update gem
echo
read -p "Press enter to update gem..."
gem update

echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install Node.js and NPM
#echo
#read -p "Press enter to install nodejs and npm..."
#yum --enablerepo=epel -y install nodejs npm

# install Middleman
echo
read -p "Press enter to install middleman..."
gem install middleman

# install Redcarpet (for Markdown file processing)
echo
read -p "Press enter to install redcarpet..."
gem install redcarpet

# install Rouge (for code syntax highlighting)
echo
read -p "Press enter to install rouge..."
gem install rouge

# install BitBalloon gem
#echo
#read -p "Press enter to install the BitBalloon gem..."
#gem install bitballoon

# Middleman web root
#mkdir -p /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -R $USER_NAME:$USER_NAME $_
#echo "made directory: $_ and set permissions to $USER_NAME"

# Middleman repository
echo
read -p "Press enter to create repos directory for $USER_NAME..."
MM_DIRECTORY="/home/$USER_NAME/repos/$MIDDLEMAN_DOMAIN"
if [ -d $MM_DIRECTORY ]; then
   echo "$MM_DIRECTORY directory already exists"
else
   mkdir -p $MM_DIRECTORY
   echo "made directory: $_"
fi

# change to repos directory
echo
read -p "Press enter to change to repos directory..."
cd $MM_DIRECTORY
echo "changed directory to $_"

# generate a blog template for Middleman
echo
echo "Before proceeding, make sure to fork $UPSTREAM_REPO and change the project name to $MIDDLEMAN_PROJECT on GitHub"
read -p "Press enter to clone $MIDDLEMAN_PROJECT from GitHub..."
if [ -d "$MM_DIRECTORY/$MIDDLEMAN_PROJECT" ]; then
   echo "middleman-homepage directory already exists"
else
   #git clone git@github.com:keegoid/middleman-homepage.git
   git clone https://github.com/keegoid/$MIDDLEMAN_PROJECT.git
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=html5
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=blog
fi

# change to newly cloned directory
echo
read -p "Press enter to change to set permissions and cd to project directory..."
chown -R $USER_NAME:$USER_NAME $MM_DIRECTORY
echo "set permissions on $MM_DIRECTORY to $USER_NAME"
cd $MIDDLEMAN_PROJECT
echo "changed directory to $_"

# assign the original repository to a remote called "upstream"
echo
read -p "Press enter to assign upstream repository..."
git remote add upstream https://github.com/$UPSTREAM_REPO && echo "remote upstream added for https://github.com/$UPSTREAM_REPO"

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
echo
read -p "Press enter to configure the Gemfile..."
egrep -i "rouge" Gemfile
if [ $? -eq 0 ]; then
   echo "Rouge syntax highligting already configured"
else
   echo '# Ruby based syntax highlighting' >> Gemfile
   echo 'gem "rouge"' >> Gemfile
   echo "rouge added to Gemfile"
fi
egrep -i "middleman-bitballoon" Gemfile
if [ $? -eq 0 ]; then
   echo "BitBalloon extension already configured"
else
   echo '' >> Gemfile
   echo '# Middleman extension for deploying to BitBalloon' >> Gemfile
   echo 'gem "middleman-bitballoon"' >> Gemfile
   echo "middleman-bitballoon added to Gemfile"
fi

# configure BitBalloon extension in config.rb
echo
read -p "Press enter to configure config.rb..."
egrep -i "bitballoon.build_before" config.rb
if [ $? -eq 0 ]; then
   echo "BitBalloon extension already configured"
else
   egrep -i "BB_TOKEN" /home/$USER_NAME/.bash_profile
   if [ $? -eq 0 ]; then
      echo "BB_TOKEN already entered in .bash_profile for user: $USER_NAME"
   else
      read -e -p "Paste your BitBalloon app token here..." GET_TOKEN
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

# change back to home directory
cd /home/$USER_NAME
echo "changed directory to /home/$USER_NAME"
echo
echo "done with middleman.sh"

