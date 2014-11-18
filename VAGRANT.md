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

Log into the virtual machine with `vagrant ssh`

_This part will take a while..._

When it is done go to:
`http://localhost:8999` where you will see a directory listing. If so, you are ready to head over to [the Field Notes section of INSTALL.md](https://github.com/stamen/fieldpapers/blob/master/INSTALL.md#field-papers). Do everthing those instructions tell you to do after the "Field Notes" section


Logging
-------
From the fieldpapers checkout on your host machine

*Apache error log:*
`vagrant ssh -c "tail -f /var/log/apache2/error.log"`

*System log file:*
`vagrant ssh -c "tail -f /var/log/syslog"`

*Celery logging*
`vagrant ssh -c "screen -r celery"`

