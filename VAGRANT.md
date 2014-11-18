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

Looks like I am missing some things from the earlier install section, too:

	sudo install Crypt_HMAC HTTP_Request DB
	sudo pear install Crypt_HMAC2 MDB2 MDB2#mysql

And need to run make in the `site` directory, but for that I need `curl`

	sudo apt-get install curl

Then I can run make, which downloads Smarty!

Definitely need to create the MySQL database.

Definitely need to edit init.php. But what is required and what can be ignored?

To see what's going wrong, try accessing the website at `localhost:8999/site/www/`, and watch the apache error logs with `tail /var/log/apache2/error.log`

When editing init.php, you could follow the init.php file on the production copy of field papers. At least, I learned I needed this:

    define('DB_DSN', 'mysql://fieldpapers:w4lks@localhost/fieldpapers');





Get the Blob Detector package directly from PIP and install it on ...
May need to ask Migurski to reupload the package? @standardpixel will work on this.


redis client is expected to be a global, but somehow it's not (problem with the pear install?). Either need to install it somewhere else, or include it from php?



Permissions issue:
symlinking to the existing fieldpapers repo in the host machine (NFS mount) doesn't work. So you can clone the