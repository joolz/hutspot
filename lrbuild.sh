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

find $DXPSERVERDIR -name "${PROJECT}*" -exec rm -rf {} \;
sleep 5s

TARGETS=`find . -type d -name target | grep -v .hg | grep -v "/bin/"`

for TARGET in $TARGETS; do
	pushd $TARGET
	cp -v *.?ar $DXPDEPLOYDIR
	popd
done
