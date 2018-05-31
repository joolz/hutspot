#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

mvn clean || exit 1
mvn package || exit 1

PROJECT=${PWD##*/}

if [ "$PROJECT" != "nl-ou-dlwo-legacy-theme" ]; then
	find $DXPSERVERDIR -name "${PROJECT}*" -exec rm -rf {} \;
fi

sleep 5s

TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/"`

for TARGET in $TARGETS; do
	pushd $TARGET
	ARS=`ls *.?ar`
	for AR in $ARS; do
		if [ "$AR" = *"portlet-service"* ]; then
			echo "Will skip $AR"
		else
			cp -v $AR $DXPDEPLOYDIR
		fi
	done
	popd
done
