#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

BAD_REBEL=`find . -name rebel.xml -exec grep -lL "$WORKSPACE_LOCATION" {} \;`

if [ -n "$BAD_REBEL" ]; then
	echo "We have bad rebel files"
	echo ${BAD_REBEL}
	exit 1
fi

find . -type d -name .sass_cache -exec rm -r {} \;

mvn clean || exit 1
mvn package || exit 1

PROJECT=${PWD##*/}
PROJECT=`basename $PROJECT`

CURDIR=`pwd`
removeNonOsgi $CURDIR

copyArtifacts

