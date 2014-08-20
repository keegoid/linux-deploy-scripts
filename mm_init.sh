#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* initialize a base Middleman site with the  "
echo "* HTML5 Boilerplate, middleman-blog          "
echo "* extension and Zurb's Foundation 5          "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# variables
DOMAIN='keeganmullaney.com'

# configure the Gemfile with necessary Middleman extensions
# middleman-syntax (Rouge)
if cat Gemfile | grep -q "middleman-syntax"; then
   echo "middleman-syntax extension already added"
else
   echo
   read -p "Press enter to configure the Gemfile..."
   echo '# Ruby based syntax highlighting utilizing Rouge' >> Gemfile
   echo 'gem "middleman-syntax"' >> Gemfile
   echo "middleman-syntax added to Gemfile"
fi
# middleman-blog
if cat Gemfile | grep -q "middleman-blog"; then
   echo "middleman-blog extension already added"
else
   echo
   read -p "Press enter to configure the Gemfile..."
   echo '# The Middleman blog extension' >> Gemfile
   echo 'gem "middleman-blog"' >> Gemfile
   echo "middleman-blog added to Gemfile"
fi

# view templates ready to install
read -p "Press enter to view available Middleman templates..."
middleman init --help

# generate the site from the html5 and blog templates
read -p "Press enter to initialize a Middleman site for $DOMAIN..."
middleman init $DOMAIN --template=html5
middleman init $DOMAIN --template=blog
cd $DOMAIN
echo "changing directory to $_"


