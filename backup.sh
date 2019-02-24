#!/bin/bash

# add the path of folders you want to backup in below array
folders=(/home /usr/local/bin /var/www /var/repo /backup/dbbackup /etc/nginx /etc/postfix)

backup_time=`date +%b-%d-%y`

for i in "${folders[@]}"; do
	dest=`basename $i`
	
	# c: to create a new archive, p: preserve file permissions, z: to compress the archive using gzip, f: the name of new archive
	tar -cpzf /backup/$dest-$backup_time.tar.gz $i
done
