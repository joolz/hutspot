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
PROJECT=`basename $PROJECT`

CURDIR=`pwd`
removeNonOsgi $CURDIR

copyArtifacts

