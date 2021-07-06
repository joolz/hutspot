#!/bin/bash

source ~/bin/common.sh || exit 1
source $CREDSFILE || exit 1

if [ ! -f pom.xml ]; then
	echo No pom
	exit 1
fi

UTF="UTF-8"
ASCII="ASCII"
HTML="HTML"
ERRORFILE="$TMP/ERRORFILE.removethis"
VERSION=${DXPVERSION}
PORTLETONLY=false
CHECKALLDEPRECATIONS=true
# comma separated
MUSTINSTALL="nl.ou.yl.domain nl-ou-dlwo-bridges"

# handle parameters
for i in "$@"
do
	case $i in
			-v=*|--version=*)
				VERSION="${i#*=}"
				;;
			-p|--portletonly)
				PORTLETONLY=true
				;;
			*)
				;;
	esac
done

echo "Will build for version ${VERSION}"

# cleanup first. Hope this doesn't interfere with concurrent builds
rm -f ${ERRORFILE}
mvn clean
find . -type d -name .sass_cache -exec rm -r {} \;

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
	echo "We have bad rebel files: do(es) not contain ${WORKSPACE_LOCATION}"
	echo ${BAD_REBEL}
	read -r -n 1 -p "${1:-Remove them and continue?} [y/n]: " REPLY
	
	case $REPLY in
      [yY])
				rm ${BAD_REBEL}
				;;
      *)
				exit 1
				;;
    esac
fi

DEPRECATIONSFOUND=false

echo "Do checks for ${VERSION} (most common deprecation)"
STRINGBUNDLER=`find . -type f -name "*java" -exec grep -l "import com.liferay.portal.kernel.util.StringBundler;" {} \;`
if [ ! -z "${STRINGBUNDLER}" ]; then
	echo "Old (non-petra) stringbundlers found ${STRINGBUNDLER}"
	DEPRECATIONSFOUND=true
fi

if [ ${CHECKALLDEPRECATIONS} = true ]; then
	echo "Now check all deprecations from https://help.liferay.com/hc/en-us/articles/360017901312-Classes-Moved-from-portal-service-jar-"
	while read DEPRECATED; do
		echo -n "."
		KEY=`echo "${DEPRECATED}" | cut -d '=' -f1`
		FOUND=`find . -type f -name "*java" -exec grep -l "${KEY}" {} \;`
		if [ ! -z "${FOUND}" ]; then
			echo
			echo "======================================================" >> ~/Desktop/deprecatedlog.log
			echo "Fix deprecated import ${KEY} in ${FOUND}" >> ~/Desktop/deprecatedlog.log
			DEPRECATIONSFOUND=true
		fi
	done < ~/bin/72codereplacements.txt
fi

if [ ${DEPRECATIONSFOUND} = true ]; then
	exit 1
fi

echo

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

if [ "$PORTLETONLY" = true ]; then
	copyArtifacts "portlet-only"
else
	copyArtifacts
fi
