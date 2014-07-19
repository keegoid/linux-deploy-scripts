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
   chown -R $USER_NAME:$USER_NAME $_
   echo "made directory: $_ and set permissions to $USER_NAME"
fi

# change to repos directory
echo
read -p "Press enter to change to repos directory..."
cd $MM_DIRECTORY
echo "changed directory to $_"

# generate a blog template for Middleman
echo
read -p "Press enter to clone Middleman project from GitHub..."
if [ -d "$MM_DIRECTORY/middleman-homepage" ]; then
   echo "middleman-homepage directory already exists"
else
   #git clone git@github.com:keegoid/middleman-homepage.git
   git clone https://github.com/keegoid/middleman-homepage.git
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=html5
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=blog
fi

# change to newly cloned directory
echo
read -p "Press enter to change to project directory..."
cd middleman-homepage
echo "changed directory to $_"

# assign the original repository to a remote called "upstream"
echo
read -p "Press enter to assign upstream repository..."
if [ -d "$MM_DIRECTORY/middleman-homepage" ]; then
   echo "remote upstream already exists"
else
   git remote add upstream https://github.com/BitBalloon/middleman-homepage
   echo "remote upstream repository added"
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
echo
read -p "Press enter to configure the Gemfile..."
egrep -i "rouge" Gemfile
if [ $? -eq 0 ]; then
   echo "Rouge syntax highligting already configured"
else
   echo '' >> Gemfile
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

# install the bundle
echo
read -p "Press enter to install the bundle..."
bundle install

# build the site from the source folder, exports static files to the build directory and pushes them to BitBalloon
echo
read -p "Press enter to build middleman and push to BitBalloon..."
bundle exec middleman deploy
#bundle exec middleman build

# run the local middleman server
echo
read -p "Press enter to run the local middleman server at http://localhost:4567/"
bundle exec middleman

# commit changes to git
echo
read -p "Press enter to commit changes in git..."
git commit -am "first commit by $USER_NAME"

# push commits to remote repository stored on GitHub
echo
read -p "Press enter to push changes to GitHub..."
git push origin master
#git push master

# deploy build directory to BitBalloon
#read -p "Press enter to deploy to BitBalloon..."
#bitballoon deploy build

# change back to home directory
cd
echo "changed directory to $HOME"
echo
echo "go to BitBalloon site and click: \"Link site to a Github repo\" link in the bottom right corner"
echo "choose which branch you want to deploy (typically master)"
echo "set the dir to \"Other ...\" and enter \"/build\""
echo "for the build command, set: \"bundle exec middleman build\""
echo "now whenever you push to Github, we'll run middleman and deploy the /build folder to your site."
echo
echo "done with middleman.sh"

