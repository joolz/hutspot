#!/bin/bash

RUN=`ps -ef | grep tomcat | grep liferay | grep -v grep | wc -l`

if [ "$RUN" -ne "0" ]; then
	echo Stop liferay first
	exit 1
fi

rm -r /opt/liferay-6.2/portal/tomcat-7.0.62/temp
rm -r /opt/liferay-6.2/portal/tomcat-7.0.62/work
rm -r /opt/liferay-6.2/portal/tomcat-7.0.62/webapps/nl-ou-dlwo-maildigest-ext*

cd /opt/liferay-6.2/portal/tomcat-7.0.62/webapps/ROOT/WEB-INF || exit 1
rm ext-nl-ou-dlwo-maildigest-ext.xml

cd lib || exit 1
rm ext-nl-ou-dlwo-maildigest-ext-impl.jar
rm ext-nl-ou-dlwo-maildigest-ext-util-bridges.jar
rm ext-nl-ou-dlwo-maildigest-ext-util-java.jar
rm ext-nl-ou-dlwo-maildigest-ext-util-taglib.jar

cd /opt/liferay-6.2/workspace/nl-ou-dlwo-maildigest || exit 1
mvn clean package liferay:deploy

echo Now start, stop and start liferay
