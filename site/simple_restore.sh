#!/bin/bash
echo 'Restoring fieldpapers database and files directory'
site_archive=$1
backup_name=$(basename "$1" .tar.gz)
tar -xzvf $site_archive
cd $backup_name

echo 'restoring database...'
mysql -u fieldpapers -pw4lks fieldpapers < fieldpapers_db.sql

echo 'restore files...'
rsync -r ./files/ /usr/local/fieldpapers/site/www/files/
