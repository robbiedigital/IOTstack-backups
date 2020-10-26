#!/bin/bash

if [ -f ~/IOTstack/backups/dropbox ]; then
	#setup variables
	dropboxuploader=~/Dropbox-Uploader/dropbox_uploader.sh
	dropboxlog=~/IOTstack/backups/log_dropbox.txt

	#list older files to be deleted from cloud (exludes last 7)
	#to change dropbox backups retained, change below -7 to whatever you want
	echo "checking for old backups on dropbox"
	files=$($dropboxuploader list | awk {' print $3 '} | tail -n +2 | grep backup | head -n -7)

	#write files to be deleted to dropbox logfile
	sudo touch $dropboxlog
	sudo chown pi:pi $dropboxlog
	echo $files | tr " " "\n" >$dropboxlog

	#delete files from dropbox as per logfile
	echo "deleting old backups from dropbox if they exist - last 7 files are kept"

	#check older files exist on dropbox, if yes then delete them
	if [ $( echo "$files" | grep -c "backup") -ne 0 ] ; then
		input=$dropboxlog
		while IFS= read -r file
		do
	    	$dropboxuploader delete $dropboxfolder/$file
		done < "$input"
	fi

	echo "backups deleted from dropbox" >>$dropboxlog
fi