Installing Field Papers
=======================

This guide has been tested on Ubuntu 12.10 (and was previously used to install
Field Papers on Ubuntu 10.04).

System
------

There are a few packages that you will need to install: some base material,
packaged for use by the offline image decoder, and packages to help run the
public-facing website. During the steps below, you'll be asked to create a root
MySQL password a few times, it's fine to leave this blank.

```bash
% apt-get update
% apt-get install build-essential gdal-bin git-core screen \
                  mysql-server default-jre-headless \
                  redis-server \
                  libapache2-mod-php5 php-pear php5-gd php5-mysql \
                  python-beautifulsoup python-cairo python-dev \
                  python-gdal python-imaging python-numpy python-pip \
                  python-requests

% pip install ModestMaps
% pip install BlobDetector
% pip install celery

% pecl install redis
```
    
Field Papers uses server packages from PHP's PEAR collection. The can be
installed via the pear utility. Some of the packages below will throw warnings
about deprecation, don't worry about those.

```bash
% pear install Crypt_HMAC HTTP_Request DB
% pear install Crypt_HMAC2 MDB2 MDB2#mysql
```

A few other details...
    
```bash
% ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
```


Field Papers
------------

Download the Field Papers project to `/usr/local/fieldpapers`.
    
```bash
% git clone -b v2.0.0 https://github.com/stamen/fieldpapers.git /usr/local/fieldpapers
% cd /usr/local/fieldpapers/site && make
```

Apache's default configuration will need to be edited slightly. This will set
the default virtual host's DocumentRoot to `/usr/local/fieldpapers/site/www`
and reload the configuration.

```bash
% sed -i 's/DocumentRoot.*/DocumentRoot \/usr\/local\/fieldpapers\/site\/www/' /etc/apache2/sites-available/default
% /etc/init.d/apache2 reload
```

Set up a new MySQL database for the site.
    
```bash
% cat <<EOF | mysql -u root
create database fieldpapers character set='utf8';
grant select, insert, update, delete, lock tables on fieldpapers.* to fieldpapers@localhost identified by 'w4lks';
EOF

% mysql -u root fieldpapers < /usr/local/fieldpapers/site/doc/create.mysql
```
    
Finally, set up site configuration by duplicating a new `init.php` and modifying
the settings to match your own database, chosen API password, Yahoo and Flickr
API keys, and other details.
    
```bash
% cp /usr/local/fieldpapers/site/lib/init.php.txt /usr/local/fieldpapers/site/lib/init.php
% sensible-editor /usr/local/fieldpapers/site/lib/init.php
```

Tasks
-----

Field Papers uses [Celery](http://www.celeryproject.org/) to manage
asynchronous tasks like creating prints and decoding scans. (Celery in turn
used Redis to communicate between the PHP front-end and the Python tasks.)

Now try Field Papers in a browser to see it work. If you try to make a new
print, you'll see a note that Field Papers is "Preparing your print".  Leave
the window open for now. You will need to start Celery for print tasks to run:

```bash
% cd /usr/local/fieldpapers/decoder
% celery -A poll worker
```

You'll see a few messages scroll by, and eventually the print page will be
replaced by an image of your selected area and a PDF download link. Print it,
scan it, or just convert it to a JPEG, and post the image back to your instance
of Field Papers.

If you've made it this far, you should have a complete working instance of
Field Papers. As a last step, add Celery to `upstart` so it will start on boot:

```bash
% cp conf/celery.conf /etc/init
% start celery
```

(It will be running in a `screen` session as the `ubuntu` user, so you can use
`screen -r celery` to inspect the queue's status.)

That's it - you're done!

Tweaks, Gotchas
---------------

Many of PHP's internal settings are restrictive by default, for safety. You'll
want to modify these for yourself, in Apache's `.htaccess` files or the file
`/etc/php5/apache2/php.ini` on Ubuntu systems. See PHP documentation on
[runtime configuration](http://www.php.net/manual/en/configuration.php) for
more information.

* Increase [`upload_max_filesize`](http://php.net/manual/en/ini.core.php#ini.upload-max-filesize)
  to accept file uploads larger than the default 2MB.
* Increase [`post_max_size`](http://php.net/manual/en/ini.core.php#ini.post-max-size)
  to allow room for larger uploaded files.

Add Redis to the list of registered PHP extensions:

```bash
% echo "extension=redis.so" > /etc/php5/conf.d/20-redis.ini
```

PHP sessions are brief by default, but a few tweaks can make them more durable.

* Increase [`session.gc_maxlifetime`](http://php.net/manual/en/session.configuration.php#ini.session.gc-maxlifetime)
  to days or weeks so that visitors stay logged-in for longer periods of time.
* To make it more efficient to keep sessions available for longer periods of time, set
  [`session.save_path`](http://php.net/manual/en/session.configuration.php#ini.session.save-path)
  to use a number of number of directory levels for session files. You'll need
  to run `ext/session/mod_files.sh` from the PHP source for this to work, and probably set
  [`session.hash_bits_per_character`](http://php.net/manual/en/session.configuration.php#ini.session.hash-bits-per-character)
  to `4` just to be safe.

When atlases or snapshots fail, the `/tmp` directory can fill up. Add a few
find-and-delete commands to `/etc/crontab` to keep these files from piling up
and filling the disk:

```
10 *    * * *   ubuntu  find /tmp -cmin +360 -name 'preblobs-*.jpg' -delete
20 *    * * *   ubuntu  find /tmp -cmin +360 -name 'highpass-*.jpg' -delete
30 *    * * *   ubuntu  find /tmp -cmin +360 -name 'postblob-*.png' -delete
40 *    * * *   ubuntu  find /tmp -cmin +360 -name 'cairoutils-*.???' -delete
```
