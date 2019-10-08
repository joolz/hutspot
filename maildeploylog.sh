#!/bin/bash

# Get the part of the tomcat log starting with the deployment, up until the end and mail it.

source ~/bin/common.sh || exit 1
source $CREDSFILE

if [ -z "$1" ]; then
	logger "$0 called without parameters"
	echo Usage: $0 projectname mailto_address
	echo
	echo For example: $0 nl-ou-dlwo-fubar-portlet
	exit 1
fi

if [ -z "$2" ]; then
	logger "$0 called with too little parameters"
	echo Usage: $0 projectname mailto_address
	echo
	echo For example: $0 nl-ou-dlwo-fubar-portlet
	exit 1
fi

LOGFILE=$DXPTOMCATDIR/logs/catalina.out
PROJECTSTRING="$1"
MAILTO="$2"
DEPLOYSTRING="^[0-9].*Processing $PROJECTSTRING.*war$"

FOUND=`grep -n -m1 -e "$DEPLOYSTRING" $LOGFILE`
if [ -z "$FOUND" ]; then
	logger "$DEPLOYSTRING not found in $LOGFILE"
	exit 1
fi

LINE_NUMBER=`echo $FOUND | cut -d : -f 1`

LOGPART=`cat $LOGFILE | awk "NR >= $LINE_NUMBER"`

echo "$LOGPART" | mailx -S "smtp=$SMTP_HOST" -s "deploy log of $1" $MAILTO

