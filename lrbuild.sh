#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE

ARGUMENT=$1 # currently: 7.2 or nothing (default to 7.0)
UTF="UTF-8"
ASCII="ASCII"
HTML="HTML"
ERRORFILE="$TMP/ERRORFILE.removethis"

# comma separated
MUSTINSTALL="nl.ou.yl.domain nl-ou-dlwo-bridges"

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

# cleanup first. Hope this doesn't interfere with concurrent builds
rm -f ${ERRORFILE}
mvn clean

find . -name 'Language*.properties' -print0 | while IFS= read -r -d $'\0' FILE; do
	ENCODING=`file -b ${FILE} | awk -F " " '{print $1}'`
	if [ "${ENCODING}" != "${UTF}" ] && [ "${ENCODING}" != "${ASCII}" ] && [ "${ENCODING}" != "${HTML}" ]; then
		FULLPATH=`readlink -f ${FILE}`
		echo ${FULLPATH} has encoding ${ENCODING}
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

if [ "${ARGUMENT}" == "7.2" ]; then
	echo "Do checks for 7.2"
	STRINGBUNDLER=`find . -type f -name "*java" -exec grep -l "import com.liferay.portal.kernel.util.StringBundler;" {} \;`
	if [ ! -z "${STRINGBUNDLER}" ]; then
		echo "Old (non-petra) stringbundlers found ${STRINGBUNDLER}"
		exit 1
	fi

#	while read DEPRECATED; do
#		FOUND=`find . -type f -name "*java" -exec grep -l "${DEPRECATED}" {} \;`
#		if [ ! -z "${FOUND}" ]; then
#			echo "Fix deprecated import ${DEPRECATED} according to https://help.liferay.com/hc/en-us/articles/360017901312-Classes-Moved-from-portal-service-jar-"
#			exit 1
#		fi
#	done < ~/bin/deprecated_in_71.txt

fi

find . -type d -name .sass_cache -exec rm -r {} \;

mvn package || exit 1

CURDIR=${PWD##*/}
for I in ${MUSTINSTALL//,/ }
do
	if [ "$I" == "$CURDIR" ]; then
		echo "mvn install $I"
		mvn install || exit 1
	fi
done


PROJECT=${PWD##*/}
PROJECT=`basename $PROJECT`

CURDIR=`pwd`
removeNonOsgi $CURDIR

copyArtifacts ${ARGUMENT}
