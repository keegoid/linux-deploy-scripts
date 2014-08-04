linux-deploy-scripts
====================

A collection of Bash scripts to perform initial setup of a fresh Centos 7.0 x86_64 workstation or server.

Applicable to setup of: SSH, restricting root permissions, IPv4 and IPv6 firewalls, useful shell [aliases][1], update Linux and install useful programs, LEMP stack, [Nginx][2] with the [ngx_cache_purge module][3], Nginx configs, [WordPress][4] and/or [Middleman][5] apps, adding a swap file, [git][6] and a few more things depending on if you choose a server or workstation install.

I would like to thank [nixCraft][7] for providing many clear and useful code examples.

## Reasoning

As I've been learning more about Linux and Bash scripting, I've found scripting deployment tasks helps me to remember:

1. what tasks to perform
1. how to execute them
1. the task execution sequence

The time it takes to setup a new Linux system with the software and settings I want has been greatly reduced.

If these scripts help you to better understand CentOS or Linux in general, or if they help you to accomplish your own deployment, please do let me know: [@keegoid][8]

The process of turning manual Shell commands into Bash scripts has not only helped me to learn Linux, but also to decide on conventions for consistent and reliable configuration of servers or workstations.

## Usage

Run these commands from the Linux Terminal either via SSH to your remote server or directly on your Linux workstation.

Change to working directory and set execute permissions:
```shell
cd deploy
chmod u+x setup.sh
```

Remove any DOS-style line breaks:
```shell
dos2unix -k setup.sh
```

I've found these DOS line breaks can creep into files through copying code from websites. The errors it causes can be ambiguous, so I make it a habit to run dos2unix each time before running a Linux script.

Finally, execute the script like this:
```shell
./setup.sh
```

## Configuration

Edit global variables in **setup.sh** before running. For example:

```shell 
# set new Linux user name, SSH port number and website domain name
REAL_NAME='Keegan Mullaney'
USER_NAME='kmullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='22' #set your own custom port number here
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
MIDDLEMAN_PROJECT="mm-${MIDDLEMAN_DOMAIN%.*}"
UPSTREAM_REPO='BitBalloon/middleman-homepage'
GITHUB_USER='keegoid' #your GitHub username

# set software versions to latest
EPEL_VERSION='7-0.2'
REMI_VERSION='7'
RPMFORGE_VERSION='0.5.3-1'
NGINX_VERSION='1.7.3'
OPENSSL_VERSION='1.0.1h'
ZLIB_VERSION='1.2.8'
PCRE_VERSION='8.35'
FRICKLE_VERSION='2.1'
RUBY_VERSION='2.1.2'

# programs to install
# use " " as delimiter
REQUIRED_PROGRAMS='wget man lynx'
SERVER_PROGRAMS=''
WORKSTATION_PROGRAMS='gedit k3b ntfs-3g git'

# what services, TCP and UDP ports we allow from the Internet
# use " " as delimiter
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
```

## Contributing

I welcome contributions and pull requests. I'm sure there are many bugs and better or more standard ways of scripting this stuff. I look forward to learning from you!

#### getting started

A clear intro to [using git][9].  
A good [step-by-step guide][10] about how to contribute to a GitHub project like this one.

#### steps

1. Fork it http://github.com/keegoid/linux-deploy-scripts/fork
1. Clone your own fork using HTTPS or SSH (recommended)
    - HTTPS: `git clone https://github.com/yourusername/linux-deploy-scripts.git`
    - SSH: `git clone git@github.com:yourusername/linux-deploy-scripts.git`
1. Optionally create your own feature branch `git checkout -b my-new-feature`
1. Commit your changes `git commit -am 'made some changes'`
1. Push your changes master or branch commits to GitHub
    - `git push origin master`
    - `git push origin my-new-feature`
1. Create a new [Pull request][11]

## About My Workflow

After much tribulation with markdown editors and various workflows, I've found what I think is a great way to create/maintain all my markdown docs. 

The writing service I use is called [Draft][12]. As of August 2014, it works with GitHub Flavored Markdown except for strikethrough and alignment of table columns.

I then *Export* my document to Dropbox so whenever I make changes it automatically syncs with my git repository in Dropbox (which then syncs with my computers and phone).

If you didn't start by cloning an existing repository on GitHub, you'll need to add your remote origin URL:

`git remote add origin git@github.com:yourusername/linux-deploy-scripts.git`

From my Linux workstation, I perform:

`git commit -am 'updated README'`

and push my changes to GitHub:

`git push origin master`

If you set the default push method for git to **matching** with:

`git config --global push.default matching`

Then you can simply use `git push` from your current branch whether master or some other branch.

I hope you find this workflow as easy and efficient as I do. Writing in Draft is a real pleasure. Tip: press F11 to write without distractions in full-screen mode.

## License

Author : Keegan Mullaney  
Company: KM Authorized LLC  
Website: http://kmauthorized.com

MIT: http://kma.mit-license.org


[1]: http://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
[2]: http://nginx.org/
[3]: http://labs.frickle.com/nginx_ngx_cache_purge/
[4]: http://wordpress.org/
[5]: http://middlemanapp.com/
[6]: http://git-scm.com/
[7]: http://www.cyberciti.biz/faq
[8]: https://twitter.com/intent/tweet?screen_name=keegoid&text=Loving%20your%20CentOS%207.0%20Deploy%20Scripts%20for%20%40middlemanapp%20or%20%40WordPress%20with%20%40nginxorg%20at%20https%3A%2F%2Fgithub.com%2Fkeegoid%2Flinux-deploy-scripts
[9]: https://www.atlassian.com/git/tutorial/git-basics#!overview
[10]: https://help.github.com/articles/fork-a-repo
[11]: https://help.github.com/articles/using-pull-requests
[12]: https://draftin.com