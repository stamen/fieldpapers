Using Vagrant for development
===

To make Field Papers easier to install and test, you can use [Vagrant](vagrantup.com).

Requirements
---
For development on OSX, you need to install:

* [Vagrant](vagrantup.com)
* [VirtualBox](https://www.virtualbox.org)
* ansible (`brew install ansible`)

Setup
---
From the root fieldpapers directory, run `vagrant up`.

This will create, provision, and launch the virtual machine.

_This part will take a while..._

Log into the virtual machine with `vagrant ssh`

When it is done go to:
`http://192.168.33.10` where you will see your locally running version of fieldpapers.  Create a user account and you are ready to go.

Logging
-------
From the fieldpapers checkout on your host machine

*Apache error log:*
`vagrant ssh -c "tail -f /var/log/apache2/error.log"`

*System log file:*
`vagrant ssh -c "tail -f /var/log/syslog"`

*Celery logging*
`vagrant ssh -c "screen -r celery"`

"mysql --user=fieldpapers --password=w4lks fieldpapers"

