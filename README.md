linux-deploy-scripts
====================

A collection of [shell scripts][ss] to perform initial setup of a [CentOS 7.0 x64][centos] workstation or server.

server option  
- tested to work on [DigitalOcean Droplets][do]
- installs [WordPress][wp] with [nginx][nginx] and [ngx_cache_purge][frickle]

workstation option  
- installs [Middleman][mm] for static websites
- configures automatic builds on [BitBalloon][bb] after each [git][git] push to [GitHub][gh].

## table of contents

- [features](#features)
- [reasoning](#reasoning)
- [usage](#usage)
- [configuration](#configuration)
- [contributing](#contributing)
   - [getting started](#getting-started)
   - [steps](#steps)
- [workflow](#workflow)
   - [Markdown](#markdown)
   - [git remote](#git-remote)
   - [git push and pull](#git-push-and-pull)
- [license](#license)

## features

- [SSH][ssh] settings
- restrict root access
- IPv4 and IPv6 firewalls
- useful [shell aliases][sa]
- update Linux and install useful programs
- LEMP stack that includes a custom built [Nginx][nginx] with the [ngx_cache_purge module][frickle]
- Nginx configs with fastcgi_cache and conditional cache purge
- [WordPress][wp] at [DigitalOcean][do] or [Middleman][mm] on your workstation with a build connection between your [GitHub][gh] account and [BitBalloon][bb] static site hosting
- a swap file on [DigitalOcean][do]
- [git][git] and a few more things depending on if you choose a server or workstation install

## reasoning

As I've been learning more about Linux and Bash scripting, I've found scripting deployment tasks helps me to remember:

1. what tasks to perform
1. how to execute them
1. the task execution sequence

The time it takes to setup a new Linux system with the software and settings I want has been greatly reduced.

If these scripts help you to better understand [CentOS][centos], [shell scripting][ss], Linux in general or if they help you to accomplish your own deployment, please do let me know: [@keegoid][twitter]

The process of turning manual shell commands into [shell scripts][ss] has not only helped me to learn Linux, but also to decide on conventions for consistent and reliable configuration of servers or workstations.

## usage

Run these commands from the [Linux console][lc] either via [SSH][ssh] to your remote server or directly on your Linux workstation.

Before you can use these scripts, you must first clone them to your workstation or server. Copy the code from the **init.sh** file in this GitHub project and save it to a new file in your **repos** directory:

```bash
mkdir -p ~/repos
cd repos
vi init.sh
```

Or if you're using [Dropbox][db]:

```bash
cd ~/Dropbox
mkdir -p Repos
cd Repos
vi init.sh
```

Paste in the code by pressing `a` to enter *Insert* mode and then `ctrl+shift+v`. **Edit the input variables at the top to reflect your information.** Save and exit with `Esc :wq Enter`.

Set execute permissions on **init.sh**, remove any DOS style line breaks using dos2unix and run it:

```bash
chmod u+x init.sh
yum -y install dos2unix
dos2unix -k init.sh
./init.sh
```

I've found MS-DOS style line breaks can creep into files through copying code from websites. The errors they cause can be ambiguous, so I make it a habit to run dos2unix each time before running a Linux script.

If the init script ran successfully, the project should be cloned to your system. You can save a backup copy of your new [SSH key pair][sshkey]. I prefer saving it as a secure note in [LastPass][lp]. Copy the keys from the [Linux console][lc] with `ctrl+shift+c` before clearing the screen:

```bash
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
clear
```

At this point you should read the configuration section below. Make sure to replace my input values with your own in **setup.sh**. Once that's done and the setup.sh file is saved, change to the linux-deploy-scripts directory, set execute permissions (if not done already) and run **setup.sh**:

```bash
cd linux-deploy-scripts
chmod u+x setup.sh
./setup.sh
```

## configuration

Edit global variables in **setup.sh** before running:

```bash
####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
REAL_NAME='Keegan Mullaney'
USER_NAME='kmullaney' #your Linux non-root user
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='666' #set your own custom port number
SSH_KEY_COMMENT='kma server'
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
GITHUB_USER='keegoid' #your GitHub username
####################################################
```

## contributing

I welcome contributions and pull requests. I'm sure there are many bugs and better or more standard ways of scripting this stuff. I look forward to learning from you!

#### getting started

A clear intro to [using git][learngit].  
A good [step-by-step guide][fork] about how to contribute to a GitHub project like this one.

#### steps

1. Fork it http://github.com/keegoid/linux-deploy-scripts/fork
1. Clone your own fork using HTTPS or SSH (recommended)
   - HTTPS: `git clone https://github.com/yourusername/linux-deploy-scripts.git`
   -   SSH: `git clone git@github.com:yourusername/linux-deploy-scripts.git`
1. Optionally create your own feature branch `git checkout -b my-new-feature`
1. Commit your changes `git commit -am 'made some cool changes'`
1. Push your master or branch commits to GitHub
   - `git push origin master`
   - `git push origin my-new-feature`
1. Create a new [Pull request][pull]

## workflow

#### Markdown

After much tribulation with [Markdown][md] editors and various workflows, I've found what I think is a great way to create/maintain my [Markdown][md] docs.

For blog posts or any long-form writing, [Draft][draftin] is wonderful, especially the `F11` mode. It mostly works with [GitHub Flavored Markdown][gfm] except for strikethrough and alignment of table columns. 
I then *Export* my document to the appropriate [git][git] repository in [Dropbox][db] (which then syncs with my various devices).
Finally, I commit the new document with [git][git] and push it to the remote repository (which then gets automatically built and deployed on [BitBalloon][bb]).

For other [Markdown][md] docs like *README.md* or *LICENSE.md* I find [gEdit][ge] to be easy and efficient. I can make some quick edits, commit changes in [git][git] and push them to [GitHub][gh] with just a few commands. It's also easy to repeat commits and pushes with the keyboard up arrow from the [Linux console][lc].  
to commit again: `up up enter`, to push again: `up up enter`

#### git remote

If you didn't start by cloning an existing repository on GitHub, you'll need to add your remote origin URL:

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

#### git push and pull

```bash
# commit changes with git:
git commit -am 'update README'

# set the default push and pull methods for git to "matching" with:
git config --global push.default matching
git config --global pull.default matching

# create a new branch and check it out:
git checkout -b 'branch-name'

# link the origin/<branch> with your local <branch>:
git branch -u origin/branch-name branch-name
```

Now you can simply use `git push` or `git pull` from your current branch, inluding master. It's nice to be able to reduce the length of these commands so you don't have to think about what you're pushing or pulling each time. Just make sure you've got the right branch checked out!

**long versions**

push or pull changes to/from origin (GitHub):  
`git push origin master` or `git push origin branch-name`  
`git pull origin master` or `git pull origin branch-name`

Note, use `git config --list` to view all configured options.

I hope you find this workflow as efficient and effective as I do.

## license

Author : Keegan Mullaney  
Company: KM Authorized LLC  
Website: http://kmauthorized.com

MIT: http://kma.mit-license.org


[centos]:   http://centos.org/
[lc]:       http://en.wikipedia.org/wiki/Linux_console
[ss]:       http://en.wikipedia.org/wiki/Shell_script
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[do]:       https://www.digitalocean.com/?refcode=251afd960495 "clicking this affiliate link benefits me at no cost to you"
[db]:       https://db.tt/T7Pstjg "clicking this affiliate link benefits me at no cost to you"
[bb]:       https://www.bitballoon.com/
[gh]:       https://github.com/
[nginx]:    http://nginx.org/
[frickle]:  http://labs.frickle.com/nginx_ngx_cache_purge/
[wp]:       http://wordpress.org/
[mm]:       http://middlemanapp.com/
[git]:      http://git-scm.com/
[gfm]:      https://help.github.com/articles/github-flavored-markdown
[md]:       http://daringfireball.net/projects/markdown/
[ge]:       https://wiki.gnome.org/Apps/Gedit
[twitter]:  https://twitter.com/intent/tweet?screen_name=keegoid&text=loving%20your%20CentOS%207.0%20deploy%20scripts%20for%20%40middlemanapp%20or%20%40WordPress%20with%20%40nginxorg%20https%3A%2F%2Fgithub.com%2Fkeegoid%2Flinux-deploy-scripts
[lp]:       https://lastpass.com/
[learngit]: https://www.atlassian.com/git/tutorial/git-basics#!overview
[fork]:     https://help.github.com/articles/fork-a-repo
[pull]:     https://help.github.com/articles/using-pull-requests
[draftin]:  https://draftin.com/
