#!/bin/bash

. ~/bin/common.sh

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

mvn clean || exit 1
mvn package || exit 1

PROJECT=${PWD##*/}
PORTLETDIR="${PROJECT}-portlet"

find $DXPSERVERDIR -name "${PROJECT}*" -exec rm {} \;

if [ -d "$PORTLETDIR" ]; then
	cd $PORTLETDIR/target
else
	cd target
fi

WARS=`ls *.war | wc -l`

if [ $WARS -eq 1 ]; then
	cp -v *.war $DXPDEPLOYDIR
elif [ $WARS -eq 0 ]; then
	echo Have no wars, will search for jars
	
	JARS=`ls *.jar | wc -l`

	if [ $JARS -eq 1 ]; then
		cp -v *.jar $DXPDEPLOYDIR
	else
		echo Have $JARS jars, do not know what to do
		exit 1
	fi

else
	echo Have $WARS wars, do not know what to do
	exit 1
fi
