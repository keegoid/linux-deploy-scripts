# KM Authorized LLC::Linux Deploy Scripts

A collection of Bash scripts to perform initial setup of a fresh Centos 6.5 x86_64 workstation or server.

Applicable to setup of: SSH, restricting root permissions, IPv4 and IPv6 firewalls, useful shell [aliases][1], Linux updates, LEMP stack, [Nginx][2] with the [ngx_cache_purge module][3], Nginx configs, [WordPress][4] and/or [Middleman][5] apps, adding a swap file, [git][6] and a few more things.

I would like to thank [nixCraft][7] for providing many clear and useful code examples.

## Reasoning

As I've been learning more about Linux and Bash scripting these last few months, I've found scripting deployment tasks helps me to remember:
1. what tasks to perform
1. how to execute them
1. the task execution sequence

The time it takes to setup a new Linux system with the software and settings I want has been greatly reduced. 

The process of turning Terminal commands into Bash scripts has helped me to decide on conventions about how to configure multiple severs or workstations consistently.

## Usage

Run these commands from the Linux Terminal either via SSH to your remote server or directly on your Linux workstation.

Change to working directory and set execute permissions:
```Shell
cd deploy
chmod +x setup.sh
```

Remove any DOS-style line breaks:
```Shell
dos2unix -k setup.sh
```

I've found these DOS line breaks can creep into files through copying code from websites. The errors it causes can be ambiguous, so I make it a habit to run dos2unix each time before running a Linux script.

Finally, execute the script like this:
```Shell
./setup.sh
```

## Configuration

Edit global variables in setup.sh script before running. For example:

```Shell 
# set names, email, SSH port number and domain names
REAL_NAME='Keegan Mullaney'
USER_NAME='Keegan'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='22' #set your own custom port number here
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
MIDDLEMAN_PROJECT="mm-${MIDDLEMAN_DOMAIN%.*}"
UPSTREAM_REPO='BitBalloon/middleman-homepage'

# set software versions to latest
NGINX_VERSION='1.7.2'
OPENSSL_VERSION='1.0.1h'
PCRE_VERSION='8.35'
ZLIB_VERSION='1.2.8'
FRICKLE_VERSION='2.1'
RUBY_VERSION='2.1.2'
```

**Make sure to replace my public SSH key with your own in the server_ssh.sh file so you can SSH into your server by authenticating with your private key.**

## Contributing

I welcome contributions and pull requests. I'm sure there are many bugs and better or more standard ways of scripting this stuff. I look forward to learning from you!

A clear intro to [using git][8].

A good [step-by-step guide][9] about how to contribute to a GitHub project like this one.

1. Fork it http://github.com/keegoid/linux-deploy-scripts/fork
1. Clone your own fork `git clone https://github.com/username/linux-deploy-scripts.git`
1. Optionally create your own feature branch `git checkout -b my-new-feature`
1. Commit your changes `git commit -am 'made some changes'`
1. Push your changes to GitHub `git push origin master` or for your branch `git push origin my-new-feature`
1. Create a new [Pull request][10]

## License

MIT: http://kma.mit-license.org


[1]: http://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
[2]: http://nginx.org/
[3]: http://labs.frickle.com/nginx_ngx_cache_purge/
[4]: http://wordpress.org/
[5]: http://middlemanapp.com/
[6]: http://git-scm.com/
[7]: http://www.cyberciti.biz/faq
[8]: https://www.atlassian.com/git/tutorial/git-basics#!overview
[9]: https://help.github.com/articles/fork-a-repo
[10]: https://help.github.com/articles/using-pull-requests