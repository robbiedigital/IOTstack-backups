#!/bin/bash

dropboxuploader=~/Dropbox-Uploader/dropbox_uploader.sh
backupfolder=/usr/share/hassio/backup

if [ -d "$backupfolder" ]; then

    #finding remote backup files and remove IOTstack backups
    remotefiles=$($dropboxuploader list | awk {' print $3 '} | tail -n +2 | grep -v backup)

    echo "uploading new local backup files..."

    #finding recent local backup files
    recentfiles=$(ls -Alht $backupfolder | awk {' print $9 '} | tail -n +2 | head -n 7)

    for file in $recentfiles; do
        [ -e "$backupfolder/$file" ] || continue

        if echo "$remotefiles" | grep -q "$file"; then
          echo "skipping local backup file $backupfolder/$file"
        else 
          echo "uploading local backup file $backupfolder/$file..."

          #upload new backup file to dropbox
          $dropboxuploader upload $backupfolder/$file $file
        fi
    done
    echo ""

    echo "deleting old local backup files..."

    #finding all local backup files
    localfiles=$(ls -Alht $backupfolder | awk {' print $9 '} | tail -n +2)

    #deleting old local backup files
    for file in $localfiles; do
        [ -e "$backupfolder/$file" ] || continue

        if echo "$recentfiles" | grep -q "$file"; then
          echo "skipping local backup file $backupfolder/$file"
        else 
          echo "deleting local backup file $backupfolder/$file..."

          sudo rm -f $backupfolder/$file
        fi
    done
    echo ""

    echo "deleting old remote backup files..."

    #deleting old remote backup files
    for file in $remotefiles; do
        if echo "$recentfiles" | grep -q "$file"; then
          echo "skipping remote backup file $backupfolder/$file"
        else 
          echo "deleting remote backup file $backupfolder/$file..."

          $dropboxuploader delete $file
        fi
    done
fi
