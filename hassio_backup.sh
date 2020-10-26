#!/bin/bash

dropboxuploader=~/Dropbox-Uploader/dropbox_uploader.sh
backupfolder=/usr/share/hassio/backup

if [ -d "$backupfolder" ]; then

    #finding remote backup files and remove IOTstack backups
    echo "finding remote backup files..."
    remotefiles=$($dropboxuploader list | awk {' print $3 '} | tail -n +2 | grep -v backup)

    #finding local backup files
    echo "finding local backup files..."
    localfiles=$(ls -Alht $backupfolder | awk {' print $9 '} | tail -n +2)

    for file in $localfiles; do
        [ -e "$backupfolder/$file" ] || continue

        if echo "$remotefiles" | grep -q "$file"; then
          echo "skipping $file"
        else 
          echo "uploading $file..."

          #upload new backup to dropbox
          $dropboxuploader upload $backupfolder/$file $file
        fi
    done

    #list older files to be deleted from cloud (exludes last 7)
    echo "checking for old backups on dropbox"
    deletefiles=$($dropboxuploader list | awk {' print $3 '} | tail -n +2 | grep -v backup | head -n -7)

    #delete files from dropbox
    echo "deleting old backups from dropbox if they exist - last 7 files are kept"
    for file in $deletefiles; do
        $dropboxuploader delete $file
    done
fi
