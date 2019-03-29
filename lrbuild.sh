#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

UTF="UTF-8"
ASCII="ASCII"
HTML="HTML"
ERRORFILE="ERRORFILE.removethis"

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

find . -name 'Language*.properties' -print0 | while IFS= read -r -d $'\0' FILE; do
	ENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`

	FULLPATH=`readlink -f ${FILE}`
	echo ${FULLPATH} has encoding ${ENCODING}

	if [ "${ENCODING}" != "${UTF}" ] && [ "${ENCODING}" != "${ASCII}" ] && [ "${ENCODING}" != "${HTML}" ]; then
		touch ${ERRORFILE} # one way to get out of a piped loop and check the condition
		exit
	fi
done

if [ -f ${ERRORFILE} ]; then
	rm ${ERRORFILE}
	echo "Encountered an error"
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

