Testing and installing with Vagrant
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

**rough notes begin here**

You'll find the field papers respository in /var/www

Web interface is installed in /var/www/site

You can see it from your host machine at `localhost:8999` but nothing is running? The database doesn't exist?

You need to start following the [INSTALL.md](https://github.com/stamen/fieldpapers/blob/master/INSTALL.md) steps somewhere in the "Field Papers" section. Cloning the repo is not necessary (is it?). Maybe.


Logging
-------
From the fieldpapers checkout on your host machine

*Apache error log:*
`vagrant ssh -c "tail -f /var/log/apache2/error.log"`

*System log file:*
`vagrant ssh -c "tail -f /var/log/syslog"`

*Celery logging*
`vagrant ssh -c "screen -r celery"`

