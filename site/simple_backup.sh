#!/bin/bash
echo 'Creating fieldpapers backup'
today=`date +"%Y-%m-%d"`
current_dir=`pwd`
backup_dir="fieldpapers-backup-${today}"
output_archive="${current_dir}/${backup_dir}.tar.gz"

mkdir -p $backup_dir
cd $backup_dir
mkdir -p files
rsync -r /usr/local/fieldpapers/site/www/files/ ./files/
mysqldump -u fieldpapers -pw4lks fieldpapers > fieldpapers_db.sql
cd ..
tar -zcvf $output_archive $backup_dir
echo $output_archive
rm -rf $backup_dir
