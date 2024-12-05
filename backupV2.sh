#!/bin/sh

echo "Process Started"

# Replace the `user_name` with your name on linux
$backupfolder=/home/user_name/Desktop/project/backup_file

$sqlfile=$backupfolder/all-databases-$(date +%d-%m-%Y_%H-%M-%S).sql
$zipfile=$backupfolder/all-databases-$(date +%d-%m-%Y_%H-%M-%S).gz

if sudo mysqldump --flush-logs --delete-master-logs --all-databases > $sqlfile

then
	echo "SQL file Created Successfully"
	
	if gzip -c $sqlfile > $zipfile
	
	then
		echo "Backup File Compressed Successfully"
		rm $sqlfile
	else
		echo "Error: Couldn't Compress Backup File"
		rm $sqlfile
		exit
	fi
else
	echo "Error: Couldn't Created SQL File"
	exit
fi

find $backupfolder -mtime +30 -delete

echo "Backup Folder is Up-To-Date"

echo "Process Completed"
