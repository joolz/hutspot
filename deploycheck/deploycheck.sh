#!/bin/bash

# Get the part of the tomcat log starting with the deployment, up until the end

if [ -z "$1" ]; then
	echo Usage: $0 projectname
	echo
	echo For example: $0 nl-ou-dlwo-announcements-portlet
	exit 0
fi

LOGFILE=catalina.out
#PROJECTSTRING="nl-ou-dlwo-announcements-portlet"
PROJECTSTRING="$1"
DEPLOYSTRING="^[0-9].*Processing $PROJECTSTRING.*war$"

FOUND=`grep -e "$DEPLOYSTRING" $LOGFILE`
if [ -z "$FOUND" ]; then
	echo Not found, exiting
	exit 0
fi

# it's there, now grep from this point

MATCH=`grep -e "$DEPLOYSTRING" $LOGFILE | tail -n 1`

TEMPFILE=`mktemp`
grep -A 1000 "`tac $LOGFILE | grep -m1 \"$MATCH\"`" $LOGFILE >| $TEMPFILE

echo TODO content of file is:
cat $TEMPFILE
rm $TEMPFILE

echo "TODO determine to whom to mail (pass in from bamboo?)"
echo TODO mail it

