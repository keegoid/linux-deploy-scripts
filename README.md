# KM Authorized LLC::Linux Deploy Scripts

A collection of Bash scripts to perform initial setup of a fresh Centos 6.5 x86_64 workstation or server.

Applicable to setup of: SSH, restricting root permissions, IPv4 and IPv6 firewalls, useful shell aliases, Linux updates, LEMP stack, Nginx with the ngx_cache_purge module, Nginx configs, WordPress and/or Middleman apps, adding a swap file, git and a few more things.

I would like to thank [nixCraft][6] for providing many clear and useful code examples.

## Reasoning

As I've been learning more about Linux and Bash scripting these last few months, I've found scripting deployment tasks helps me to remember:
1. what tasks to perform
1. how to execute them
1. the task execution sequence

The time it takes to setup a new Linux system with the software and settings I want has been greatly reduced. 

The process of turning Terminal commands into Bash scripts has helped me to decide on conventions about how to configure multiple severs or workstations consistently.

## Usage

Set execute permissions and remove any of the wrong type of line breaks if needed. I've found these Dos style line breaks can creep into files through copying code from a website. The errors it causes can be ambiguous, so I've found it best to make it a habit to run dos2unix each time before running a Linux script.

Run these commands from the Linux Terminal either via SSH to your remote server or directly on your new Linux workstation:

```Bash
cd deploy
chmod +x setup.sh
dos2unix -k setup.sh
./setup.sh
```

## Configuration



Make sure to replace my public SSH key with your own in the server_ssh.sh file.

## Contributing

1. Fork it ( http://github.com/keegoid/linux-deploy-scripts/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

MIT: http://kma.mit-license.org


[6]: http://www.cyberciti.biz/faq