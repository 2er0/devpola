#!/bin/bash
# /dev/pola Upload

#    devpola-upload
#    Copyright (C) 2017  ringbuchblock
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# import settings
source /home/pi/devpola/devpola-config.sh


function photosAvailable {
  if [ -z "$(ls -A $PHOTO_DIR)" ]; then
     return 1
  else
     return 0 #true
  fi
}

function internetConnectionAvailable {
  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
    return 0 #true
  else
    return 1
  fi
}

function uploadPhotos {  
  photosAvailable;
  if [ "$?" -eq "1" ]; then
    dlog "aborting... no new photos"
    return 0 #abort
  fi
  
  internetConnectionAvailable;
  if [ "$?" -eq "1" ]; then
    dlog "aborting... no internet connection"
    return 0 #abort
  fi
  
  # sync files and delete successfully synced files
  rsync -avz --remove-source-files $PHOTO_DIR $UPLOAD_DIR
  if [ ! "$?" -eq "0" ]; then
    log "Error while running rsync. Exit code: $?"
  fi
}

function main {
  log "Upload service started"

  if ! $UPLOAD_ENABLED; then
    log "Upload disabled. Exiting..."
    return 0;
  fi
  
  # main loop
  while :
  do
    uploadPhotos
    sleep $UPLOAD_INTERVAL_SECONDS
  done
}

main
