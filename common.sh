#!/bin/bash

DXPBASEDIR=/opt/dxp
DXPSOURCEDIR=$DXPBASEDIR/src
DXPSERVERDIR=$DXPBASEDIR/server
DXPTOMCATDIR=$DXPSERVERDIR/tomcat-8.0.32
DXPDEPLOYDIR=$DXPSERVERDIR/deploy
DXPDOWNLOADSDIR=~/Downloads/dxp
DXPPATCHESDIR=$DXPDOWNLOADSDIR/patches
DXPLOGDIR=$DXPBASEDIR/log

SMTP_HOST=mail.lokaal

# TODO
DB_SCHEMA=two
DB_TEMP_SCHEMA=dxp_temp

DB_DUMP_DIR=~/Desktop

TMP=$DXPBASEDIR/tmp
mkdir -p $TMP

PORTAL_EXT="/opt/liferay/portal/portal-ext.properties"

# some defaults
DB_SCHEMA=dxp
DB_USER=`grep jdbc.default.username $PORTAL_EXT | grep -v '^$\|^\s*\#' | awk -F "=" '{print $2}'`
DB_PASSWORD=`grep jdbc.default.password $PORTAL_EXT | grep -v '^$\|^\s*\#' | awk -F "=" '{print $2}'`
DB_HOST=localhost
DB_PORT=3309

DB_CHARACTER_SET=utf8
DB_DEFAULT_COLLATE=utf8_unicode_ci

SLEEP_LONG=10m
SLEEP_SHORT=2m

confirm() {
	echo $1 [yn]
	read -s -n 1 GOODTOGO
	if [ "$GOODTOGO" != "y" ]; then
		echo Bye
	exit 0
	fi
}

dxplog() {
	NOW=`date +%Y%m%d-%H:%M:%S`
	if [ "$1" == "-m" ]; then
		MESSAGE="$NOW `caller` - $2"
	else
		MESSAGE="$NOW `caller` - $1"
	fi
	echo $MESSAGE >> $DXPLOGDIR/general.log
	if [ "$1" == "-m" ]; then
		echo "$MESSAGE" | mailx -s "$MAIL_SUBJECT" -r $MAIL_FROM $MAIL_TO
	fi
}

waitforit() {
  echo -e "Waiting for $1 to complete"
  NOW=$(($(date +%s%N)/1000000))
  FIFO="$TMP/tomcat_$NOW"
  mkfifo $FIFO || exit 1
  tail -f $CATALINALOG > $FIFO &
  TAIL_PID=$!
  grep -m 1 "$2" $FIFO
  kill $TAIL_PID
  rm $FIFO
  echo -e "$1 completed."
}

convertsecs() {
	((h=${1}/3600))
	((m=(${1}%3600)/60))
	((s=${1}%60))
	printf "%02d:%02d:%02d\n" $h $m $s
}

say() {
  TIME=`date +%Y%m%d-%H%M%S`
  echo "=== HB $TIME - $1"
}

tomcatpid() {
	TOMCAT_PID=`ps -ef|grep tomcat|grep java|awk '{print $2}'`
	return $TOMCAT_PID
}

liferayrunningcheck() {
	RUN=`ps -ef | grep tomcat | grep "catalina.base" | grep -v grep | wc -l`
	if [ "$RUN" -ne "0" ]; then
		echo Liferay active, exiting
		exit 1
	fi
}

rootcheck() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root"
		exit 1
	fi
}

liferaycleanup() {
	rm -rf $DXPSERVERDIR/osgi/state
	rm -rf $DXPSERVERDIR/work
	rm -rf $DXPSERVERDIR/tomcat-8.0.32/temp
	rm -rf $DXPSERVERDIR/tomcat-8.0.32/work
}
