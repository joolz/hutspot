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

	setVersion ${PROJECT} "com.liferay.faces.bridge.impl" "4.1.4" 
	setVersion ${PROJECT} "com.liferay.faces.bridge.ext" "5.0.5"
	setVersion ${PROJECT} "com.liferay.faces.portal" "4.0.0"
	setVersion ${PROJECT} "com.liferay.faces.alloy" "3.0.1"
	setVersion ${PROJECT} "com.liferay.faces.util" "3.1.0"
	setVersion ${PROJECT} "org.primefaces" "6.1"
	setVersion ${PROJECT} "javax.faces-api" "2.2"
	setVersion ${PROJECT} "el-api" "2.2.1-b04"
	setVersion ${PROJECT} "javax.faces" "2.2.20"
	setVersion ${PROJECT} "com.liferay.portal.tools.service.builder" "1.0.324"
	setVersion ${PROJECT} "com.liferay.portal.kernel" "4.4.0"
	setVersion ${PROJECT} "javax.servlet-api" "3.0.1"
	setVersion ${PROJECT} "portlet-api" "3.0.1"
	setVersion ${PROJECT} "com.liferay.util.java" "4.0.7"
	setVersion ${PROJECT} "biz.aQute.bnd.annotation" "4.2.0"
	setVersion ${PROJECT} "org.osgi.service.component.annotations" "1.3.0"
	setVersion ${PROJECT} "javax.el-api" "3.0.1-b06"
	setVersion ${PROJECT} "jdom" "1.1.3"
	setVersion ${PROJECT} "com.liferay.wiki.api" "4.0.6"
	setVersion ${PROJECT} "commons-lang" "2.6"
	setVersion ${PROJECT} "log4j" "1.2.14"
	setVersion ${PROJECT} "com.liferay.petra.string" "3.0.0"
	setVersion ${PROJECT} "com.liferay.petra.lang" "3.0.0"
	setVersion ${PROJECT} "org.osgi.annotation.versioning" "1.1.0"
	setVersion ${PROJECT} "org.osgi.core" "6.0.0"
	setVersion ${PROJECT} "org.osgi.service.component.annotations" "1.3.0"
}

export -f processPom
export -f setVersion

find . -type f -name pom.xml -exec bash -c 'processPom "$0"' {} \;

