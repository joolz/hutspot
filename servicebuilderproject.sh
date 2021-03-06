#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage $0 PROJECTNAME"
	exit 1
fi

mvn archetype:generate \
		-DdependencyInjector=spring \
		-DarchetypeGroupId=com.liferay \
		-DarchetypeArtifactId=com.liferay.project.templates.service.builder \
		-DinteractiveMode=false \
		-DdependencyInjector=spring \
		-DgroupId=nl.ou.dlwo \
		-Dversion=1.0.0-SNAPSHOT \
		-DaddOns=false \
		-DbuildType=maven \
		-Dproduct=dxp \
		-Dpackage=nl.ou.dlwo \
		-DapiPath=-api \
		-DliferayVersion=7.2+ \
		-DartifactId=${1}

echo "Now set liferay.bom.version to ${DXPBOMVERSION} and activate standalone project."
