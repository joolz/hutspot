#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Usage $0 TIMETORECORD (in sleep format)"
	exit 1
fi

FILE="`date +%Y-%m-%d_%H:%M:%S`.ogv"
echo File is $FILE

cd ~/tmp
recordmydesktop --no-cursor --no-frame "${FILE}" &

PIDREC=`pidof recordmydesktop`
echo Have $PIDREC

# After $1...
sleep $1

# ... send SIGTERM
kill -SIGTERM  $PIDREC
