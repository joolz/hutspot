#!/bin/bash

source ~/bin/common.sh || exit 1

SERVICE=$1

if [ -z "$SERVICE" ]; then
	echo "Usage: $0 [name of osgi bundle to restart]"
	exit 1
fi

TOMCAT_PID=`tomcatpid`

if [ -z "$TOMCAT_PID" ]; then
	echo "No tomcat PID found"
	exit 1
fi

RUNNING=0
TEMPFILE=`mktemp`

while [ $RUNNING -lt 1 ]; do
   { echo "lb $SERVICE"; sleep 1; } | telnet localhost 11311 > $TEMPFILE
   BUNDLE=$(cat $TEMPFILE | grep -i $SERVICE | grep Active | awk '{print $1}')
   if [ -n "$BUNDLE" ]; then
      STOPME="$(echo $BUNDLE | cut -d'|' -f1)"
      { echo "stop $STOPME"; sleep 5; } | telnet localhost 11311 >> $TEMPFILE
      { echo "start $STOPME"; sleep 5; } | telnet localhost 11311 >> $TEMPFILE
      RUNNING=1
   else
      echo "Running: $RUNNING"
   fi
   sleep 1
done

rm -f $TEMPFILE
