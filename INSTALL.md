Installing Field Papers
=======================

This guide has been tested on Ubuntu 10.04.

System
------

There are a few packages that you will need to install: some base material,
packaged for use by the offline image decoder, and packages to help run the
public-facing website. During the steps below, you'll be asked to create a root
MySQL password a few times, it's fine to leave this blank.

    % apt-get update
    % apt-get install build-essential gdal-bin git-core libapache2-mod-php5 \
                      mysql-server-5.1 openjdk-6-jre-headless php-pear php5-gd \
                      php5-mysql python-beautifulsoup python-cairo python-dev \
                      python-gdal python-imaging python-numpy python-pip \
                      screen tcsh vim zip

    % pip install ModestMaps
    % pip install BlobDetector
    
Field Papers uses server packages from PHP's PEAR collection. The can be
installed via the pear utility. Some of the packages below will throw warnings
about deprecation, don't worry about those.

    % pear install Crypt_HMAC HTTP_Request DB
    % pear install Crypt_HMAC2 MDB2 MDB2#mysql

A few other details...
    
    % ln -s /usr/lib/libproj.so.0 /usr/lib/libproj.so
    % curl -o /tmp/lockrun.c http://www.unixwiz.net/tools/lockrun.c
    % gcc /tmp/lockrun.c -o /usr/bin/lockrun



Field Papers
------------

Download the Field Papers project to `/usr/local/fieldpapers`.
    
    % git clone -b release-1.0 git://github.com/stamen/fieldpapers.git /usr/local/fieldpapers
    % cd /usr/local/fieldpapers/site && make

Apache's default configuration will need to be edited slightly. Edit the line
with "DocumentRoot" to say `DocumentRoot /usr/local/fieldpapers/site/www`,
then restart Apache.

    % pico /etc/apache2/sites-enabled/000-default
    % apache2ctl restart

Set up a new MySQL database for the site.
    
    % mysql -u root
        > create database fieldpapers character set='utf8';
        > grant select, insert, update, delete, lock tables on fieldpapers.* to fieldpapers@localhost identified by 'w4lks';
        > flush privileges;
        > quit;
    
    % mysql -u root fieldpapers < /usr/local/fieldpapers/site/doc/create.mysql
    
Finally, set up site configuration by duplicating a new `init.php` and modifying
the settings to match your own database, chosen API password, Yahoo and Flickr
API keys, and other details.
    
    % cp /usr/local/fieldpapers/site/lib/init.php.txt /usr/local/fieldpapers/site/lib/init.php
    % pico /usr/local/fieldpapers/site/lib/init.php

Polling
-------

Now try Field Papers in a browser to see it work. If you try to make
a new print, you'll see a note that Field Papers is "Preparing your print".
Leave the window open for now. You will need to start the back-end Python
process to create prints and decode scans.

Run the poll.py process once with the password you chose above:

    % cd /usr/local/fieldpapers/decoder/
    % python poll.py -p password -b http://hostname/ once

You'll see a few messages scroll by, and eventually the print page will be
replaced by an image of your selected area and a PDF download link. Print it,
scan it, or just convert it to a JPEG, and post the image back to your instance
of Field Papers. Note that it's just sitting there, "queued for processing".
Run poll.py again to process the scan.

If you've gotten this far, you should have a complete working instance of
Field Papers. Add the call to poll.py from above to a once-per-minute cronjob,
by adding a line to `/etc/crontab` like this:

    * *     * * *   ubuntu  cd /usr/local/fieldpapers/decoder && /usr/bin/lockrun --lockfile=poll.lock -- python poll.py -p password -b http://hostname/ 55

That's it - you're done!
