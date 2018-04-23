#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

# script to check if open office is running headless

SO_INSTANCES=`ps -e | grep soffice.bin | grep -v grep | awk '{print $1;}'`
SO_NUMBER=`echo $SO_INSTANCES | wc -w`

if [ "$SO_NUMBER" -eq "0" ]; then
  say -l "SOffice was not running, is started"
  soffice --headless \
		--accept="socket,host=127.0.0.1,port=8100;urp;" \
		--nofirststartwizard
else
  if [ "$SO_NUMBER" -gt "1" ]; then
    FIRST="true"
    for OOO in $SO_INSTANCES; do
      if [ "$FIRST" = "true" ]; then
        FIRST="false"
        # dont kill the first process
      else
        say -l "Remove duplicate OOo process $OOO"
        kill -9 $OOO
      fi
    done
  fi
	say "All OK"
fi
