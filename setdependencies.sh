#!/bin/bash

# https://stackoverflow.com/questions/51440902/how-to-replace-a-specific-dependency-version-in-pom-xml-file-using-sed-command-i

function setVersion() {
	PROJECT=$1
	ARTIFACT=$2
	VERSION=$3
	FOUND=`grep "<artifactId>${ARTIFACT}</" ${PROJECT}`
	if [ ! -z "${FOUND}" ]; then
		xmlstarlet ed \
			-N N="http://maven.apache.org/POM/4.0.0" \
			-u '//N:dependency[N:artifactId = "'${ARTIFACT}'"]/N:version' \
			-v "${VERSION}" \
			${PROJECT} > ${PROJECT}.new
		ERROR=$?
		if [ "$ERROR" == 0 ]; then
			rm ${PROJECT}
			mv ${PROJECT}.new ${PROJECT}
			echo "Set ${PROJECT} artifact ${ARTIFACT} to version ${VERSION}"
		else
			echo "ERROR ${ERROR} setting ${PROJECT} artifact ${ARTIFACT} to version ${VERSION}"
			exit 1
		fi
	fi
}

function processPom() {
	PROJECT=$1
		while IFS='=' read -r KEY VALUE; do
			setVersion ${PROJECT} "${KEY}" "${VALUE}"
		done < "$VERSIONS"
}

export -f processPom
export -f setVersion

export VERSIONS="$1"

if [ -f "${VERSIONS}" ]; then
	find . -type f -name pom.xml -exec bash -c 'processPom "$0"' {} \;
else
	echo "File ${VERSIONS} not found"
	echo "Usage: $0 FILENAME"
	echo "In FILENAME the versions must be set as properties: artifact=version"
	echo "This script does not add properties, only updates existing artifacts to the version in FILENAME in all pom.xml files found in and under the current directory"
fi
