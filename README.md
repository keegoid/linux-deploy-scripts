linux-deploy-scripts
====================

A collection of [shell scripts][ss] to perform initial setup of a Fedora-based workstation or [CentOS 7.0 x64][centos] server.

init script

1. should work on most Fedora-based distros
1. installs and configures [git][git]
1. generates [RSA keys][sshkey] for remote [SSH sessions][ssh] if none exist (note: these are not [GPG keys][gpgkey])
1. clones this project and sets it as the remote upstream in [git][git]

server option

- tested to work on [DigitalOcean Droplets][do] for [CentOS 7.0 x64][centos]
- installs [WordPress][wp] with [nginx][nginx] and the [ngx_cache_purge][frickle] module

workstation option

- sets up [git][git] to provide clear examples of the commit and push/pull processes

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Features](#features)
- [Reasoning](#reasoning)
- [Usage](#usage)
      - [Download](#download)
      - [Configure](#configure)
      - [Run init.sh](#run-initsh)
      - [SSH Keys](#ssh-keys)
      - [Update software versions](#update-software-versions)
      - [Run menu.sh](#run-menush)
- [Contributing](#contributing)
      - [Getting Started](#getting-started)
      - [Steps](#steps)
- [Workflow](#workflow)
      - [Markdown](#markdown)
      - [Git Remote](#git-remote)
      - [Git Push and Pull](#git-push-and-pull)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Features

- [SSH][ssh] settings
- restrict root access
- IPv4 and IPv6 firewalls
- create useful [shell aliases][sa]
- update Linux and install useful programs
- LEMP stack that includes a custom built [Nginx][nginx] with the [ngx_cache_purge module][frickle]
- Nginx configs with fastcgi_cache and conditional cache purge
- setup SSH connection on your workstation and install [WordPress][wp] at [DigitalOcean][do]
- create a swap file on [DigitalOcean][do]
- configure [git][git] for pushing/pulling changes to [GitHub][gh]

## Reasoning

As I've been learning more about Linux and Bash scripting, I've found that by scripting my deployment tasks it helps me to remember:

1. what tasks to perform
1. how to execute them
1. the task execution sequence

The time it takes to set up a new Linux system with the software and settings I want has been greatly reduced.

If these scripts help you to better understand [CentOS][centos], [shell scripting][ss], Linux in general or if they help you to accomplish your own deployment, please do let me know: [@keegoid][twitter]

The process of turning manual shell commands into [shell scripts][ss] has not only helped me to learn about and love Linux, but also to decide on conventions for consistent and reliable configuration of servers or workstations.

## Usage

Run these commands from the [Linux console][lc] either via [SSH][ssh] to your remote server or directly on your Linux workstation.

##### Download

```bash
# download the scripts
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/config.sh
curl -kfsSLO https://raw.githubusercontent.com/keegoid/linux-deploy-scripts/master/init.sh
```

##### Configure

Open **config.sh** with your favorite text editor and **edit the input variables** at the top to reflect your information.

Optionally modify firewall services, ports or hosts.

```bash
# --------------------------------------------------
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' #Linux user you will/already use
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
SSH_PORT='666' #set your own custom port number
WORDPRESS_DOMAIN='kmauthorized.com'
GITHUB_USER='keegoid' #your GitHub username
LIBS_DIR='includes' #where you put extra stuff

# OPTIONALLY, UPDATE THESE VARIABLES
# stuff to install (use " " as delimiter)
REQUIRED_PROGRAMS='wget man lynx'
WORKSTATION_PROGRAMS='gedit gnupg2 git xclip'
SERVER_PROGRAMS=''

# what to allow from the Internet (use " " as delimiter)
SERVICES='http https smtp imaps pop3s ftp ntp'
TCP_PORTS="$SSH_PORT"
UDP_PORTS=''

# whitelisted IPs (Cloudflare)
TRUSTED_IPV4_HOSTS="199.27.128.0/21 \
173.245.48.0/20 \
103.21.244.0/22 \
103.22.200.0/22 \
103.31.4.0/22 \
141.101.64.0/18 \
108.162.192.0/18 \
190.93.240.0/20 \
188.114.96.0/20 \
197.234.240.0/22 \
198.41.128.0/17 \
162.158.0.0/15 \
104.16.0.0/12"

TRUSTED_IPV6_HOSTS="2400:cb00::/32 \
2606:4700::/32 \
2803:f800::/32 \
2405:b500::/32 \
2405:8100::/32"
# --------------------------------------------------
```

##### Run init.sh

If necessary, set execute permissions and remove any DOS style line breaks using dos2unix before running.

I've found MS-DOS style line breaks can creep into files through copying code from websites. The errors they cause can be ambiguous, so I make it a habit to run dos2unix each time before running a [shell script][ss].

```bash
chmod +x init.sh
yum -y install dos2unix
dos2unix -k init.sh
./init.sh
```

##### SSH Keys

If the init script ran successfully, the project should be cloned to your system. You can save a backup copy of your [SSH key pair][sshkey]. I prefer saving it as a secure note in [LastPass][lp]. Copy the keys from the [Linux console][lc] with `ctrl+shift+c` before clearing the screen.

```bash
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
clear
```

##### Update software versions

You'll find the default software versions in the includes/software.lib file. You can use the URLs to check for newer versions of the listed software that will get installed.


##### Run menu.sh

```bash
cd linux-deploy-scripts
chmod +x menu.sh
dos2unix -k menu.sh
./menu.sh
```

## Contributing

I welcome contributions and pull requests. I'm sure there are many bugs and better or more standard ways of scripting this stuff. I look forward to learning from you!

##### Getting Started

A clear intro to [using git][learngit].  
A good [step-by-step guide][fork] about how to contribute to a GitHub project like this one.

##### Steps

1. Fork http://github.com/keegoid/linux-deploy-scripts/fork
1. Clone your own fork using HTTPS or SSH (recommended)
   - HTTPS: `git clone https://github.com/yourusername/linux-deploy-scripts.git`
   -   SSH: `git clone git@github.com:yourusername/linux-deploy-scripts.git`
1. Optionally create your own feature branch `git checkout -b my-new-feature`
1. Commit your changes `git commit -am 'made some cool changes'`
1. Push your master or branch commits to GitHub
   - `git push origin master`
   - `git push -u origin my-new-feature`
1. Create a new [Pull request][pull]

## Workflow

##### Markdown

I keep a journal in [Markdown][md] and use [Markdown][md] for writing my blog posts as well. It's really great for any long-form writing because it gets out of your way and lets you just write.

After much tribulation with [Markdown][md] editors and various workflows in both Windows and Linux, I've found what I think is a great way to create/maintain my [Markdown][md] docs.

In Linux, for docs like *README.md* or *LICENSE.md*, I find [gEdit][ge] to be easy and efficient. I can make some quick edits, commit changes in [git][git] and push them to [GitHub][gh] with just a few commands. I use the [blackboard][bb] theme which is easy on my eyes.

It's also easy to repeat commits and pushes with the keyboard up arrow from the [Linux console][lc], which tells it to flip through the history of commands.  
After your first commit and push, to commit again from the [Linux console][lc]: `up up enter` and then to push again: `up up enter`

In Windows I use [Markdownpad][mdp]. I usually write my journal and blog entries from there. It has a nice preview pane and has some convient keyboard shortcuts for inserting the current date/time and quickly adding styles like h1, h2, h3.

##### Git Remote

If you didn't start by cloning your repository on [GitHub][gh], for example if you used `git init` on your workstation, you'll need to add your remote origin URL:

```bash
# HTTPS:
git remote add origin https://github.com/yourusername/linux-deploy-scripts.git

# SSH:
git remote add origin git@github.com:yourusername/linux-deploy-scripts.git
```

You can also set the upstream repository to fetch changes from this project:

```bash
# HTTPS:
git remote add upstream https://github.com/keegoid/linux-deploy-scripts.git

# SSH:
git remote add upstream git@github.com:keegoid/linux-deploy-scripts.git
```

Then `git fetch upstream master` and `git merge upstream/master`  
or accomplish both with `git pull upstream master`

##### Git Push and Pull

```bash
# git config
# author
git config --global user.name 'Keegan Mullaney'
git config --global user.email 'keegan@kmauthorized.com'
# select a text editor, I prefer vi, you can also use vim or something else
git config --global core.editor vi
# add some SVN-like aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.up rebase
git config --global alias.ci commit
# set the default push and pull methods for git to "matching"
git config --global push.default matching
git config --global pull.default matching

# commit changes with git
git commit -am 'update README'

########## new branch method 1 ##########

# create a new branch and check it out
git checkout -b 'branch-name'

# push changes to remote repo and set remote upstream in config
git push -u origin branch-name

# checkout the master branch again
git checkout master

########## new branch method 2 ##########

# create new branch without checking it out
git branch 'branch-name'

# push new branch to origin
git push origin 'branch-name'

# link the origin/<branch> with your local <branch>
git branch -u origin/branch-name branch-name
```

Now you can simply use `git push` or `git pull` from your current branch, including master. It's nice to be able to reduce the length of these commands so you don't have to think about what you're pushing or pulling each time. Just make sure you've got the right branch checked out!

**long versions**

push or pull changes to/from origin (GitHub):  
`git push origin master` or `git push origin branch-name`  
`git pull origin master` or `git pull origin branch-name`

Note, use `git config --list` to view all configured options.

I hope you find this workflow as efficient and effective as I do.

## License

Author : Keegan Mullaney  
Company: KM Authorized LLC  
Website: http://kmauthorized.com

MIT: http://kma.mit-license.org


[centos]:   http://centos.org/
[lc]:       http://en.wikipedia.org/wiki/Linux_console
[ss]:       http://en.wikipedia.org/wiki/Shell_script
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[gpgkey]:   http://en.wikipedia.org/wiki/GNU_Privacy_Guard
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[do]:       https://www.digitalocean.com/?refcode=251afd960495 "clicking this affiliate link benefits me at no cost to you"
[db]:       https://db.tt/T7Pstjg "clicking this affiliate link benefits me at no cost to you"
[nginx]:    http://nginx.org/
[frickle]:  http://labs.frickle.com/nginx_ngx_cache_purge/
[wp]:       http://wordpress.org/
[git]:      http://git-scm.com/
[learngit]: https://www.atlassian.com/git/tutorial/git-basics#!overview
[learncc]:  https://www.atlassian.com/git/tutorial/git-basics#!commit
[um]:       http://blogs.atlassian.com/2013/07/git-upstreams-forks/
[gh]:       https://github.com/
[bb]:       https://github.com/afair/dot-gedit/blob/master/blackboard.xml
[fork]:     https://help.github.com/articles/fork-a-repo
[pull]:     https://help.github.com/articles/using-pull-requests
[gfm]:      https://help.github.com/articles/github-flavored-markdown
[md]:       http://daringfireball.net/projects/markdown/
[mdp]:      http://markdownpad.com/
[ge]:       https://wiki.gnome.org/Apps/Gedit
[twitter]:  https://twitter.com/intent/tweet?screen_name=keegoid&text=loving%20your%20CentOS%207.0%20deploy%20scripts%20for%20%40middlemanapp%20or%20%40WordPress%20with%20%40nginxorg%20https%3A%2F%2Fgithub.com%2Fkeegoid%2Flinux-deploy-scripts
[lp]:       https://lastpass.com/
