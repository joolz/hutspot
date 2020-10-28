#!/bin/bash

usage() {
	echo "Usage $0 WIDTHxHEIGHT"
	echo "Will create a base64 image and attempt to copy it to the clipboard"
}

if [ -z "$1" ]; then
	usage
	exit 1
fi

SIZE=$1

JPGFILE=`mktemp --suffix .jpg`
BASE64FILE=`mktemp --suffix .base64`

convert -size ${SIZE} xc: +noise Random ${JPGFILE} ; \
  echo "<img src=\"data:image/jpg;base64," >| ${BASE64FILE} ; \
  base64 ${JPGFILE} >> ${BASE64FILE} ; \
  echo "\" alt=\"Random ${SIZE}\" />" >> ${BASE64FILE} ; \
  sed -i ':a;$!{N;s/\n/ /;ba;}' ${BASE64FILE}

xsel -b < ${BASE64FILE} # en paste in webcontent
FILESIZE=`ls -lh ${BASE64FILE} | awk '{print $5}'`
echo "Created ${BASE64FILE} from ${JPGFILE} with dimensions ${SIZE} and filesize ${FILESIZE} and copied it's content to the clipboard"
